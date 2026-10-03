import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/core/theme/app_colors.dart';
import 'package:free_space/core/utils/file_utils.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/data/services/native_platform_service.dart';
import 'package:free_space/presentation/providers/items_provider.dart';
import 'package:free_space/presentation/providers/storage_provider.dart';
import 'package:free_space/presentation/widgets/item_action_helpers.dart';
import 'package:free_space/presentation/widgets/item_card.dart';
import 'package:free_space/presentation/widgets/tracked_item_actions.dart';

/// Screen for displaying items in the bin ready for deletion.
class BinScreen extends ConsumerStatefulWidget {
  const BinScreen({super.key});

  @override
  ConsumerState<BinScreen> createState() => _BinScreenState();
}

class _BinScreenState extends ConsumerState<BinScreen> {
  bool _selectionMode = false;
  bool _requestingTrashAccess = false;
  final Set<int> _selectedIds = {};
  final Set<String> _selectedSystemTrashPaths = {};

  Future<void> _retrySystemTrashAccess() async {
    setState(() => _requestingTrashAccess = true);
    try {
      await ref
          .read(nativePlatformServiceProvider)
          .listSystemTrashItems(requestAccess: true);
      ref.invalidate(systemTrashItemsProvider);
    } catch (error) {
      if (mounted) showItemActionError(context, error);
    } finally {
      if (mounted) setState(() => _requestingTrashAccess = false);
    }
  }

  void _toggleSelection(TrackedItemModel item) {
    setState(() {
      if (!_selectionMode) _selectionMode = true;
      if (!_selectedIds.add(item.id)) _selectedIds.remove(item.id);
    });
  }

  void _toggleSelectAll() {
    final items = ref.read(binnedItemsProvider).valueOrNull ?? [];
    final trackedTrashPaths =
        items.map((item) => item.systemTrashPath).whereType<String>().toSet();
    final systemItems = (ref.read(systemTrashItemsProvider).valueOrNull ?? [])
        .where((item) => !trackedTrashPaths.contains(item.trashPath));
    final allSelected = items.every((item) => _selectedIds.contains(item.id)) &&
        systemItems.every(
          (item) => _selectedSystemTrashPaths.contains(item.trashPath),
        );
    setState(() {
      _selectionMode = true;
      if (allSelected) {
        _selectedIds.clear();
        _selectedSystemTrashPaths.clear();
      } else {
        _selectedIds.addAll(items.map((item) => item.id));
        _selectedSystemTrashPaths
          ..clear()
          ..addAll(systemItems.map((item) => item.trashPath));
      }
    });
  }

  void _toggleSystemTrashSelection(SystemTrashItem item) {
    setState(() {
      if (!_selectionMode) _selectionMode = true;
      if (!_selectedSystemTrashPaths.add(item.trashPath)) {
        _selectedSystemTrashPaths.remove(item.trashPath);
      }
    });
  }

  Future<void> _moveSelected(ItemCategory category) async {
    final items = ref.read(binnedItemsProvider).valueOrNull ?? [];
    final selected =
        items.where((item) => _selectedIds.contains(item.id)).toList();
    final trackedTrashPaths =
        items.map((item) => item.systemTrashPath).whereType<String>().toSet();
    final selectedSystemItems =
        (ref.read(systemTrashItemsProvider).valueOrNull ?? [])
            .where((item) =>
                _selectedSystemTrashPaths.contains(item.trashPath) &&
                !trackedTrashPaths.contains(item.trashPath))
            .toList();
    try {
      await moveTrackedItems(context, ref, selected, category);
      await moveSystemTrashItems(ref, selectedSystemItems, category);
      if (mounted) {
        setState(() {
          _selectedIds.clear();
          _selectedSystemTrashPaths.clear();
          _selectionMode = false;
        });
      }
    } catch (error) {
      if (mounted) showItemActionError(context, error);
    }
  }

  Future<void> _deleteSelected() async {
    final selectedCount =
        _selectedIds.length + _selectedSystemTrashPaths.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete selected items permanently?'),
        content: Text('Delete $selectedCount selected items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final items = ref.read(binnedItemsProvider).valueOrNull ?? [];
    try {
      final selectedItems =
          items.where((item) => _selectedIds.contains(item.id)).toList();
      if (selectedItems.any(
            (item) =>
                item.systemTrashPath != null &&
                Uri.tryParse(item.systemTrashPath!)?.scheme != 'content',
          ) &&
          !await ensureAllFilesAccess(context, ref)) {
        return;
      }
      if (selectedItems.isNotEmpty) {
        await ref.read(itemRepositoryProvider).deleteMany(
              selectedItems.map((item) => item.id).toList(),
            );
      }
      if (_selectedSystemTrashPaths.isNotEmpty) {
        final deleted = await ref
            .read(nativePlatformServiceProvider)
            .permanentlyDeleteItemsFromSystemTrash(
              _selectedSystemTrashPaths.toList(),
            );
        if (deleted.length != _selectedSystemTrashPaths.length) {
          throw StateError(
            'Only ${deleted.length} of ${_selectedSystemTrashPaths.length} selected system Trash items were permanently deleted.',
          );
        }
      }
      ref
        ..invalidate(binnedItemsProvider)
        ..invalidate(systemTrashItemsProvider)
        ..invalidate(binnedCountProvider);
      if (mounted) {
        setState(() {
          _selectedIds.clear();
          _selectedSystemTrashPaths.clear();
          _selectionMode = false;
        });
      }
    } catch (error) {
      if (mounted) showItemActionError(context, error);
    }
  }

  Future<void> _showItemActions(TrackedItemModel item) async {
    await showTrackedItemActions(
      context,
      item: item,
      onMove: (category) => moveTrackedItem(context, ref, item, category),
      onDelete: () => deleteTrackedItem(context, ref, item),
      onReveal: () => revealTrackedItem(ref, item),
    );
  }

  Future<void> _showSystemTrashItemActions(SystemTrashItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              title:
                  Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(item.trashPath,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Open/View'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                try {
                  await ref
                      .read(nativePlatformServiceProvider)
                      .showInFileManager(item.trashPath);
                } catch (error) {
                  if (mounted) showItemActionError(context, error);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Put Back to Temporary'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                try {
                  await moveSystemTrashItems(
                    ref,
                    [item],
                    ItemCategory.temporary,
                  );
                } catch (error) {
                  if (mounted) showItemActionError(context, error);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Put Back to Permanent'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                try {
                  await moveSystemTrashItems(
                    ref,
                    [item],
                    ItemCategory.permanent,
                  );
                } catch (error) {
                  if (mounted) showItemActionError(context, error);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete permanently'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete permanently?'),
                    content: Text('Delete "${item.name}" from macOS Trash?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !mounted) return;
                try {
                  final deleted = await ref
                      .read(nativePlatformServiceProvider)
                      .permanentlyDeleteItemsFromSystemTrash([item.trashPath]);
                  if (!deleted.contains(item.trashPath)) {
                    throw StateError(
                      'macOS did not confirm permanent deletion of this item.',
                    );
                  }
                  ref
                    ..invalidate(systemTrashItemsProvider)
                    ..invalidate(binnedItemsProvider);
                } catch (error) {
                  if (mounted) showItemActionError(context, error);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final binItemsAsync = ref.watch(binnedItemsProvider);
    final systemTrashAsync = ref.watch(systemTrashItemsProvider);
    final trackedBinItems = binItemsAsync.valueOrNull ?? const [];
    final trackedTrashPaths = trackedBinItems
        .map((item) => item.systemTrashPath)
        .whereType<String>()
        .toSet();
    final visibleSystemTrashItems =
        (systemTrashAsync.valueOrNull ?? const <SystemTrashItem>[])
            .where((item) => !trackedTrashPaths.contains(item.trashPath))
            .toList();
    final allBinItemsSelected =
        (trackedBinItems.isNotEmpty || visibleSystemTrashItems.isNotEmpty) &&
            trackedBinItems.every((item) => _selectedIds.contains(item.id)) &&
            visibleSystemTrashItems.every(
                (item) => _selectedSystemTrashPaths.contains(item.trashPath));
    final hasSelectedTrackedItems =
        trackedBinItems.any((item) => _selectedIds.contains(item.id));
    final hasSelectedItems =
        hasSelectedTrackedItems || _selectedSystemTrashPaths.isNotEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'bin_select',
        onPressed: () => setState(() {
          _selectionMode = !_selectionMode;
          _selectedIds.clear();
          _selectedSystemTrashPaths.clear();
        }),
        tooltip: _selectionMode ? 'Exit selection' : 'Select items',
        child: Icon(_selectionMode ? Icons.close : Icons.checklist),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Bin'),
            actions: [
              if (_selectionMode)
                TextButton(
                  onPressed: _toggleSelectAll,
                  child: Text(
                    allBinItemsSelected ? 'Deselect all' : 'Select all',
                  ),
                ),
              if (_selectionMode && hasSelectedItems)
                PopupMenuButton<String>(
                  tooltip: 'Move or delete selected items',
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) {
                    if (action == 'temporary') {
                      _moveSelected(ItemCategory.temporary);
                    } else if (action == 'permanent') {
                      _moveSelected(ItemCategory.permanent);
                    } else {
                      _deleteSelected();
                    }
                  },
                  itemBuilder: (context) => [
                    if (hasSelectedItems) ...[
                      const PopupMenuItem(
                        value: 'temporary',
                        child: Text('Restore to Temporary'),
                      ),
                      const PopupMenuItem(
                        value: 'permanent',
                        child: Text('Move to Permanent'),
                      ),
                    ],
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete permanently'),
                    ),
                  ],
                ),
              if (_selectionMode)
                TextButton(
                  onPressed: () => setState(() {
                    _selectionMode = false;
                    _selectedIds.clear();
                    _selectedSystemTrashPaths.clear();
                  }),
                  child: Text(
                    'Cancel (${_selectedIds.length + _selectedSystemTrashPaths.length})',
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Empty Bin',
                onPressed: () => _confirmEmptyBin(context, ref),
              ),
            ],
          ),
        ],
        body: binItemsAsync.when(
          data: (unsortedItems) {
            final items = List.of(unsortedItems);
            items.sort((a, b) {
              final aDate = a.binnedAt ?? a.temporarySince ?? a.createdAt;
              final bDate = b.binnedAt ?? b.temporarySince ?? b.createdAt;
              final cmp = aDate.compareTo(bDate);
              return cmp != 0 ? cmp : b.sizeBytes.compareTo(a.sizeBytes);
            });
            final trackedTrashPaths = items
                .map((item) => item.systemTrashPath)
                .whereType<String>()
                .toSet();
            final systemItems = (systemTrashAsync.valueOrNull ?? [])
                .where((item) => !trackedTrashPaths.contains(item.trashPath))
                .toList();
            if (items.isEmpty && systemItems.isEmpty) {
              if (systemTrashAsync.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (systemTrashAsync.hasError) {
                return _buildSystemTrashError(context, systemTrashAsync.error!);
              }
              return _buildEmptyState(context);
            }

            final int totalSize = items.fold(
              systemItems.fold<int>(0, (sum, item) => sum + item.sizeBytes),
              (sum, item) => sum + item.sizeBytes,
            );
            final totalItems = items.length + systemItems.length;

            return Column(
              children: [
                // Bin summary
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 20,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.rose.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.rose,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$totalItems items in Bin',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${FileUtils.formatFileSize(totalSize)} available to reclaim',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref
                        ..invalidate(binnedItemsProvider)
                        ..invalidate(systemTrashItemsProvider);
                    },
                    child: Scrollbar(
                      interactive: true,
                      thickness: 6.0,
                      radius: const Radius.circular(10),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children: [
                          if (systemTrashAsync.hasError)
                            _buildSystemTrashError(
                              context,
                              systemTrashAsync.error!,
                            ),
                          ...items.map((item) => _buildTrackedItem(item)),
                          if (systemItems.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
                              child: Text(
                                'Already in macOS Trash',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                              child: Text(
                                'These items were moved to Trash outside Free Space.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ),
                            ...systemItems.map(_buildSystemTrashCard),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildTrackedItem(TrackedItemModel item) {
    return Dismissible(
      key: Key(item.id.toString()),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        color: Colors.green,
        child: const Icon(Icons.restore, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      direction:
          _selectionMode ? DismissDirection.none : DismissDirection.horizontal,
      onDismissed: (direction) async {
        try {
          if (direction == DismissDirection.startToEnd) {
            await moveTrackedItem(
              context,
              ref,
              item,
              ItemCategory.temporary,
            );
          } else {
            await deleteTrackedItem(context, ref, item);
          }
        } catch (error) {
          if (mounted) showItemActionError(context, error);
        }
      },
      child: ItemCard(
        item: item,
        selectionMode: _selectionMode,
        selected: _selectedIds.contains(item.id),
        onTap: _selectionMode
            ? () => _toggleSelection(item)
            : () => _showItemActions(item),
        onLongPress: () => _toggleSelection(item),
        onDoubleTap: () async {
          try {
            await revealTrackedItem(ref, item);
          } catch (error) {
            if (mounted) showItemActionError(context, error);
          }
        },
      ),
    );
  }

  Widget _buildSystemTrashCard(SystemTrashItem item) {
    return Dismissible(
      key: Key('system-${item.trashPath}'),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.green,
        child: const Icon(Icons.restore, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      direction:
          _selectionMode ? DismissDirection.none : DismissDirection.horizontal,
      onDismissed: (direction) async {
        try {
          if (direction == DismissDirection.startToEnd) {
            await moveSystemTrashItems(
              ref,
              [item],
              ItemCategory.temporary,
            );
          } else {
            final deleted = await ref
                .read(nativePlatformServiceProvider)
                .permanentlyDeleteItemsFromSystemTrash([item.trashPath]);
            if (!deleted.contains(item.trashPath)) {
              throw StateError(
                'macOS did not confirm permanent deletion of this item.',
              );
            }
            ref.invalidate(systemTrashItemsProvider);
          }
        } catch (error) {
          ref.invalidate(systemTrashItemsProvider);
          if (mounted) showItemActionError(context, error);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: _selectionMode
              ? Icon(
                  _selectedSystemTrashPaths.contains(item.trashPath)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: _selectedSystemTrashPaths.contains(item.trashPath)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.rose.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      const Icon(Icons.delete_outline, color: AppColors.rose),
                ),
          title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${FileUtils.formatFileSize(item.sizeBytes)} · System Trash',
          ),
          trailing: _selectionMode ? null : const Icon(Icons.more_horiz),
          onTap: () async {
            if (_selectionMode) {
              _toggleSystemTrashSelection(item);
              return;
            }
            await _showSystemTrashItemActions(item);
          },
          onLongPress: () => _toggleSystemTrashSelection(item),
        ),
      ),
    );
  }

  Widget _buildSystemTrashError(BuildContext context, Object error) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 10),
            Text(
              'Could not read system Trash',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed:
                  _requestingTrashAccess ? null : _retrySystemTrashAccess,
              icon: _requestingTrashAccess
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(
                _requestingTrashAccess
                    ? 'Requesting access...'
                    : 'Retry / Allow access',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 68,
            color: AppColors.sage,
          ),
          const SizedBox(height: 16),
          Text(
            'Your bin is empty!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'No space wasted here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }

  void _confirmEmptyBin(BuildContext context, WidgetRef ref) {
    final trackedItems = ref.read(binnedItemsProvider).valueOrNull ?? [];
    final trackedTrashPaths = trackedItems
        .map((item) => item.systemTrashPath)
        .whereType<String>()
        .toSet();
    final systemItems = (ref.read(systemTrashItemsProvider).valueOrNull ?? [])
        .where((item) => !trackedTrashPaths.contains(item.trashPath))
        .toList();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Empty Bin?'),
        content: Text(
          'This will permanently delete all ${trackedItems.length + systemItems.length} items in the bin, including items in macOS Trash. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              try {
                final includesAppManagedFiles = trackedItems.any(
                  (item) =>
                      item.systemTrashPath != null &&
                      Uri.tryParse(item.systemTrashPath!)?.scheme != 'content',
                );
                if (includesAppManagedFiles &&
                    !await ensureAllFilesAccess(context, ref)) {
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  return;
                }
                final latestSystemItems = await ref
                    .read(nativePlatformServiceProvider)
                    .listSystemTrashItems();
                final latestTrackedItems =
                    ref.read(binnedItemsProvider).valueOrNull ?? [];
                final latestTrackedTrashPaths = latestTrackedItems
                    .map((item) => item.systemTrashPath)
                    .whereType<String>()
                    .toSet();
                final latestExternalItems = latestSystemItems
                    .where((item) =>
                        !latestTrackedTrashPaths.contains(item.trashPath))
                    .toList();
                await ref.read(itemRepositoryProvider).emptyBin();
                if (latestExternalItems.isNotEmpty) {
                  final deleted = await ref
                      .read(nativePlatformServiceProvider)
                      .permanentlyDeleteItemsFromSystemTrash(
                        latestExternalItems
                            .map((item) => item.trashPath)
                            .toList(),
                      );
                  if (deleted.length != latestExternalItems.length) {
                    throw StateError(
                      'Only ${deleted.length} of ${latestExternalItems.length} macOS Trash items were permanently deleted.',
                    );
                  }
                }
              } catch (error) {
                if (context.mounted) showItemActionError(context, error);
              } finally {
                ref
                  ..invalidate(binnedItemsProvider)
                  ..invalidate(systemTrashItemsProvider)
                  ..invalidate(binnedCountProvider);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Empty'),
          ),
        ],
      ),
    );
  }
}
