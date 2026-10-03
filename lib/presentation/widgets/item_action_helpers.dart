import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/services/native_platform_service.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/presentation/providers/items_provider.dart';
import 'package:free_space/presentation/providers/storage_provider.dart';

Future<void> revealTrackedItem(WidgetRef ref, TrackedItemModel item) async {
  final opened = await ref
      .read(nativePlatformServiceProvider)
      .showInFileManager(item.systemTrashPath ?? item.path);
  if (!opened) {
    throw StateError('The file manager could not reveal this item.');
  }

  // Removed updateLastUsed to keep timer intact when merely viewing.
}

Future<void> moveTrackedItem(
  BuildContext context,
  WidgetRef ref,
  TrackedItemModel item,
  ItemCategory category,
) async {
  final nativeService = ref.read(nativePlatformServiceProvider);
  final repository = ref.read(itemRepositoryProvider);
  if (_needsAllFilesAccess(context, item, category) &&
      !await ensureAllFilesAccess(context, ref)) {
    throw StateError('All files access was not granted. No files were moved.');
  }
  if (category == ItemCategory.binned && item.category != ItemCategory.binned) {
    if (item.path.contains('Free Space Bin') || !File(item.path).existsSync()) {
      // File is already deleted or already in the app's bin. Just update DB.
      await repository.moveItemsToBin({item.id: item.path});
    } else {
      final moved = await nativeService.moveItemsToSystemTrash([item.path]);
      if (!moved.containsKey(item.path)) {
        throw StateError(
            'The system did not move this item to its Trash. (File might be missing or permission denied)');
      }
      await repository.moveItemsToBin({item.id: moved[item.path]});
    }
  } else {
    if (item.category == ItemCategory.binned &&
        category != ItemCategory.binned &&
        item.systemTrashPath != null) {
      await nativeService.restoreItemsFromSystemTrash([
        (originalPath: item.path, trashPath: item.systemTrashPath),
      ]);
    }
    await repository.categorizeMany([item.id], category);
  }
  _refreshItemLists(ref);
}

Future<void> deleteTrackedItem(
  BuildContext context,
  WidgetRef ref,
  TrackedItemModel item,
) async {
  if (item.category == ItemCategory.binned &&
      _usesAppManagedBin(item) &&
      !await ensureAllFilesAccess(context, ref)) {
    throw StateError(
        'All files access was not granted. No files were deleted.');
  }
  await ref.read(itemRepositoryProvider).deletePermanently(item.id);
  _refreshItemLists(ref);
}

Future<void> moveTrackedItems(
  BuildContext context,
  WidgetRef ref,
  List<TrackedItemModel> items,
  ItemCategory category,
) async {
  if (items.isEmpty) return;
  if (items.any((item) => _needsAllFilesAccess(context, item, category)) &&
      !await ensureAllFilesAccess(context, ref)) {
    throw StateError('All files access was not granted. No files were moved.');
  }
  final repository = ref.read(itemRepositoryProvider);
  final nativeService = ref.read(nativePlatformServiceProvider);
  if (category == ItemCategory.binned) {
    final existingPaths = items
        .where((i) =>
            File(i.path).existsSync() && !i.path.contains('Free Space Bin'))
        .map((i) => i.path)
        .toList();
    final moved = existingPaths.isEmpty
        ? <String, String?>{}
        : await nativeService.moveItemsToSystemTrash(existingPaths);

    final movedIds = <int, String?>{};
    for (final item in items) {
      if (!File(item.path).existsSync() ||
          item.path.contains('Free Space Bin')) {
        movedIds[item.id] = item.path;
      } else if (moved.containsKey(item.path)) {
        movedIds[item.id] = moved[item.path];
      }
    }
    if (movedIds.isNotEmpty) {
      await repository.moveItemsToBin(movedIds);
    }
    if (movedIds.length != items.length) {
      throw StateError(
        'Only ${movedIds.length} of ${items.length} selected items were moved to system Trash.',
      );
    }
  } else {
    final trashedItems = items
        .where((item) =>
            item.category == ItemCategory.binned &&
            item.systemTrashPath != null)
        .toList();
    if (trashedItems.isNotEmpty) {
      await nativeService.restoreItemsFromSystemTrash(
        trashedItems
            .map((item) => (
                  originalPath: item.path,
                  trashPath: item.systemTrashPath,
                ))
            .toList(),
      );
    }
    await repository.categorizeMany(
      items.map((item) => item.id).toList(),
      category,
    );
  }
  _refreshItemLists(ref);
}

bool _needsAllFilesAccess(
  BuildContext context,
  TrackedItemModel item,
  ItemCategory destination,
) {
  if (Theme.of(context).platform != TargetPlatform.android) return false;
  if (destination == ItemCategory.binned) return item.type != ItemType.media;
  return item.category == ItemCategory.binned && _usesAppManagedBin(item);
}

bool _usesAppManagedBin(TrackedItemModel item) {
  final trashPath = item.systemTrashPath;
  return trashPath != null && Uri.tryParse(trashPath)?.scheme != 'content';
}

Future<bool> ensureAllFilesAccess(
  BuildContext context,
  WidgetRef ref,
) async {
  if (Theme.of(context).platform != TargetPlatform.android) return true;
  final nativeService = ref.read(nativePlatformServiceProvider);
  if (await nativeService.hasAllFilesAccess()) return true;
  if (!context.mounted) return false;

  final consent = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Allow access to manage files?'),
      content: const Text(
        'Android only allows media files in its System Bin. To move or restore '
        'documents such as PDFs and contacts, Free Space needs All files '
        'access. This grants broad access to shared files, not only the '
        'selected item. Files moved to Bin are kept in “Download/Free Space Bin”.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Continue to Settings'),
        ),
      ],
    ),
  );
  if (consent != true || !context.mounted) return false;
  return nativeService.requestAllFilesAccess();
}

Future<void> moveSystemTrashItems(
  WidgetRef ref,
  List<SystemTrashItem> items,
  ItemCategory category,
) async {
  if (items.isEmpty) return;
  if (category == ItemCategory.binned) {
    throw ArgumentError.value(
        category, 'category', 'Items are already in Bin.');
  }

  final restored = await ref
      .read(nativePlatformServiceProvider)
      .putBackSystemTrashItems(items.map((item) => item.trashPath).toList());
  try {
    if (restored.isNotEmpty) {
      final registeredCount = await ref
          .read(itemRepositoryProvider)
          .registerRestoredPaths(restored.values.toList(), category);
      if (registeredCount == 0) {
        throw StateError(
          'Finder put the selected item back, but Free Space could not register it in $category.',
        );
      }
    }
  } finally {
    _refreshItemLists(ref);
  }

  if (restored.length != items.length) {
    throw StateError(
      'Finder put back ${restored.length} of ${items.length} selected items. Items Finder could not restore remain in macOS Trash.',
    );
  }
}

void _refreshItemLists(WidgetRef ref) {
  ref
    ..invalidate(temporaryItemsProvider)
    ..invalidate(binnedItemsProvider)
    ..invalidate(systemTrashItemsProvider)
    ..invalidate(temporaryCountProvider)
    ..invalidate(permanentCountProvider)
    ..invalidate(binnedCountProvider);
  ref.read(permanentItemsRevisionProvider.notifier).state++;
}

void showItemActionError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Could not complete item action: $error')),
  );
}
