import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:free_space/core/constants/app_constants.dart';
import 'package:free_space/data/repositories/settings_repository.dart';
import 'package:free_space/presentation/providers/items_provider.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';
import 'package:free_space/presentation/providers/notification_provider.dart';
import 'package:free_space/presentation/providers/storage_provider.dart';
import 'package:free_space/presentation/widgets/adaptive_scaffold.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/data/services/sync_service.dart';

/// The root shell for the home screens, providing navigation structure.
class HomeShell extends ConsumerStatefulWidget {
  /// The navigation shell provided by GoRouter.
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  bool _purging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _purgeExpiredItems());
    _scheduleNextInactivityCheck();
    _setupFileObserver();
  }

  void _setupFileObserver() async {
    final nativeService = ref.read(nativePlatformServiceProvider);
    nativeService.setOnNewFileDetected((data) {
      _handleNewFileDetected(data);
    });

    try {
      final downloads = await nativeService.getDownloadsPath();
      await nativeService.startFileObserver([downloads]);
    } catch (e) {
      developer.log('Could not start file observer on downloads', error: e);
    }
  }

  Future<void> _handleNewFileDetected(Map<String, dynamic> data) async {
    final path = data['path'] as String?;
    final name = data['name'] as String?;
    final sizeBytes = (data['sizeBytes'] as num?)?.toInt() ?? 0;
    if (path == null || name == null) return;

    // Show notification for background handling
    await ref
        .read(notificationServiceProvider)
        .showNewItemNotification(name, path, sizeBytes);

    if (!mounted) return;
    final result = await showDialog<ItemCategory>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('New Item Detected'),
        content: Text('How would you like to store "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ItemCategory.temporary),
            child: const Text('Temporary'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ItemCategory.permanent),
            child: const Text('Permanent'),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref.read(itemRepositoryProvider).trackNewFile(path, result, name);
      // Cancel the notification since we handled it in the app
      await ref
          .read(notificationServiceProvider)
          .cancelNotification(path.hashCode);
    }

    if (result != null && mounted) {
      final item = TrackedItemModel(
        id: 0,
        name: name,
        path: path,
        type: ItemType.file,
        sizeBytes: sizeBytes,
        category: result,
        createdAt: DateTime.now(),
        lastUsedAt: DateTime.now(),
        isFlagged: false,
      );
      try {
        await ref.read(itemRepositoryProvider).addItem(item);
        if (result == ItemCategory.temporary) {
          ref.invalidate(temporaryItemsProvider);
          ref.invalidate(temporaryCountProvider);
        } else {
          ref.invalidate(permanentCountProvider);
          ref.read(permanentItemsRevisionProvider.notifier).state++;
        }
      } catch (e) {
        developer.log('Failed to add new detected item', error: e);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _purgeExpiredItems();
      ref.read(syncServiceProvider).performSync();
    }
  }

  void _scheduleNextInactivityCheck() {
    _inactivityTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _inactivityTimer = Timer(nextDay.difference(now), () {
      if (mounted) ref.invalidate(temporaryItemsProvider);
      _purgeExpiredItems();
      if (mounted) _scheduleNextInactivityCheck();
    });
  }

  Future<void> _purgeExpiredItems() async {
    if (_purging || !mounted) return;
    _purging = true;
    final repository = ref.read(itemRepositoryProvider);
    try {
      final settings = ref.read(settingsRepositoryProvider);
      final inactivityDays = await settings.getInactivityDays();
      var movedToTemporary = 0;
      if (await settings.getOperationMode() == OperationMode.autoBin) {
        movedToTemporary =
            await repository.moveInactivePermanentItemsToTemporary(
          inactivityDays,
        );
      }
      if (movedToTemporary > 0) {
        ref.read(permanentItemsRevisionProvider.notifier).state++;
        ref
          ..invalidate(permanentCountProvider)
          ..invalidate(temporaryItemsProvider)
          ..invalidate(temporaryCountProvider);
      }
      final movedToBin = await repository.autoBinInactiveItems(inactivityDays);
      if (movedToBin > 0) {
        try {
          await ref
              .read(notificationServiceProvider)
              .showBinNotification(movedToBin);
        } catch (error, stackTrace) {
          developer.log(
            'Could not send the automatic Bin notification',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
      if ((movedToTemporary > 0 || movedToBin > 0) && mounted) {
        ref
          ..invalidate(temporaryItemsProvider)
          ..invalidate(permanentCountProvider)
          ..invalidate(binnedItemsProvider)
          ..invalidate(systemTrashItemsProvider)
          ..invalidate(temporaryCountProvider)
          ..invalidate(binnedCountProvider);
        final messages = <String>[];
        if (movedToTemporary > 0) {
          messages.add(
            '$movedToTemporary inactive Permanent ${movedToTemporary == 1 ? 'item moved' : 'items moved'} to Temporary',
          );
        }
        if (movedToBin > 0) {
          messages.add(
            '$movedToBin expired Temporary ${movedToBin == 1 ? 'item moved' : 'items moved'} to Bin',
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${messages.join('. ')}.')),
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'Could not complete automatic storage transitions',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not auto-move inactive items: $error')),
        );
      }
    }
    try {
      final deletedCount =
          await repository.purgeExpiredBinItems(AppConstants.binRetentionDays);
      if (deletedCount > 0 && mounted) {
        ref
          ..invalidate(binnedItemsProvider)
          ..invalidate(systemTrashItemsProvider)
          ..invalidate(binnedCountProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$deletedCount expired ${deletedCount == 1 ? 'item was' : 'items were'} permanently deleted.',
            ),
          ),
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'Could not permanently delete expired system Trash items',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not clear expired Bin items: $error')),
        );
      }
    } finally {
      _purging = false;
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(operationModeProvider, (_, next) {
      if (next.hasValue) _purgeExpiredItems();
    });
    ref.listen(inactivityDaysProvider, (_, next) {
      if (next.hasValue) _purgeExpiredItems();
    });

    return PopScope(
      canPop: widget.navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
        }
      },
      child: AdaptiveScaffold(
        currentIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Temporary',
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_outline),
            selectedIcon: Icon(Icons.lock),
            label: 'Permanent',
          ),
          NavigationDestination(
            icon: Icon(Icons.delete_outline),
            selectedIcon: Icon(Icons.delete),
            label: 'Bin',
          ),
        ],
        child: widget.navigationShell,
      ),
    );
  }
}
