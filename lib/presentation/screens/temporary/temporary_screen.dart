import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/core/constants/app_constants.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/presentation/providers/items_provider.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';
import 'package:free_space/presentation/widgets/item_action_helpers.dart';
import 'package:free_space/presentation/widgets/item_card.dart';
import 'package:free_space/presentation/widgets/tracked_item_actions.dart';

/// The temporary items screen showing items that might be unused.
class TemporaryScreen extends ConsumerStatefulWidget {
  const TemporaryScreen({super.key});

  @override
  ConsumerState<TemporaryScreen> createState() => _TemporaryScreenState();
}

class _TemporaryScreenState extends ConsumerState<TemporaryScreen> {
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  void _toggleSelection(TrackedItemModel item) {
    setState(() {
      if (!_selectionMode) _selectionMode = true;
      if (!_selectedIds.add(item.id)) _selectedIds.remove(item.id);
    });
  }

  void _toggleSelectAllVisible() {
    final items = ref.read(temporaryItemsProvider).valueOrNull ?? [];
    final filter = ref.read(itemFilterProvider);
    final visibleItems = items.where((item) {
      return switch (filter) {
        ItemFilter.all => true,
        ItemFilter.media => item.type == ItemType.media,
        ItemFilter.files => item.type == ItemType.file,
        ItemFilter.apps => item.type == ItemType.app,
      };
    }).toList();
    setState(() {
      _selectionMode = true;
      if (visibleItems.every((item) => _selectedIds.contains(item.id))) {
        _selectedIds.removeAll(visibleItems.map((item) => item.id));
      } else {
        _selectedIds.addAll(visibleItems.map((item) => item.id));
      }
    });
  }

  Future<void> _moveSelected(ItemCategory category) async {
    final items = ref.read(temporaryItemsProvider).valueOrNull ?? [];
    final selected =
        items.where((item) => _selectedIds.contains(item.id)).toList();
    try {
      await moveTrackedItems(context, ref, selected, category);
      if (mounted) {
        setState(() {
          _selectedIds.clear();
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

  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(itemFilterProvider);
    final currentSort = ref.watch(itemSortProvider);
    final itemsAsync = ref.watch(temporaryItemsProvider);
    final inactivityDays = ref.watch(inactivityDaysProvider).valueOrNull ??
        AppConstants.defaultInactivityDays;
    final availableItems = itemsAsync.valueOrNull ?? const <TrackedItemModel>[];
    final filteredItems = availableItems.where((item) {
      return switch (currentFilter) {
        ItemFilter.all => true,
        ItemFilter.media => item.type == ItemType.media,
        ItemFilter.files => item.type == ItemType.file,
        ItemFilter.apps => item.type == ItemType.app,
      };
    }).toList();
    
    filteredItems.sort((a, b) {
      switch (currentSort) {
        case ItemSort.daysUnused:
          return a.daysUntilBinned(inactivityDays).compareTo(b.daysUntilBinned(inactivityDays));
        case ItemSort.size:
          return b.sizeBytes.compareTo(a.sizeBytes);
        case ItemSort.name:
          return a.name.compareTo(b.name);
      }
    });

    final allVisibleSelected = filteredItems.isNotEmpty &&
        filteredItems.every((item) => _selectedIds.contains(item.id));

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text('Temporary Storage'),
            floating: true,
            snap: true,
            actions: [
              if (_selectionMode)
                TextButton(
                  onPressed: _toggleSelectAllVisible,
                  child:
                      Text(allVisibleSelected ? 'Deselect all' : 'Select all'),
                ),
              if (_selectionMode)
                PopupMenuButton<ItemCategory>(
                  tooltip: 'Move selected items',
                  icon: const Icon(Icons.drive_file_move),
                  onSelected: _moveSelected,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: ItemCategory.permanent,
                      child: Text('Move to Permanent'),
                    ),
                    PopupMenuItem(
                      value: ItemCategory.binned,
                      child: Text('Move to Bin'),
                    ),
                  ],
                ),
              if (_selectionMode)
                TextButton(
                  onPressed: () => setState(() {
                    _selectionMode = false;
                    _selectedIds.clear();
                  }),
                  child: Text('Cancel (${_selectedIds.length})'),
                ),
              PopupMenuButton<ItemSort>(
                icon: const Icon(Icons.sort),
                initialValue: currentSort,
                onSelected: (sort) {
                  ref.read(itemSortProvider.notifier).state = sort;
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: ItemSort.daysUnused,
                    child: Text('Sort by Days Unused'),
                  ),
                  PopupMenuItem(
                    value: ItemSort.size,
                    child: Text('Sort by Size'),
                  ),
                  PopupMenuItem(
                    value: ItemSort.name,
                    child: Text('Sort by Name'),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(49.0),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _FilterChipWidget(
                          label: 'All',
                          value: ItemFilter.all,
                          currentValue: currentFilter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChipWidget(
                          label: 'Media',
                          value: ItemFilter.media,
                          currentValue: currentFilter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChipWidget(
                          label: 'Files',
                          value: ItemFilter.files,
                          currentValue: currentFilter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChipWidget(
                          label: 'Apps',
                          value: ItemFilter.apps,
                          currentValue: currentFilter,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(temporaryItemsProvider);
          },
          child: itemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return _buildEmptyState(context);
              }
              final visibleItems = items.where((item) {
                if (currentFilter == ItemFilter.media) {
                  return item.type == ItemType.media;
                }
                if (currentFilter == ItemFilter.files) {
                  return item.type == ItemType.file;
                }
                if (currentFilter == ItemFilter.apps) {
                  return item.type == ItemType.app;
                }
                return true;
              }).toList()
                ..sort((a, b) {
                  switch (currentSort) {
                    case ItemSort.daysUnused:
                      final cmp = a.daysUntilBinned(inactivityDays).compareTo(b.daysUntilBinned(inactivityDays));
                      return cmp != 0 ? cmp : b.sizeBytes.compareTo(a.sizeBytes);
                    case ItemSort.size:
                      return b.sizeBytes.compareTo(a.sizeBytes);
                    case ItemSort.name:
                      return a.name.compareTo(b.name);
                  }
                });
              return Scrollbar(
                interactive: true,
                thickness: 6.0,
                radius: const Radius.circular(10),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: visibleItems.length,
                  itemBuilder: (context, index) {
                    final item = visibleItems[index];
                    return ItemCard(
                      item: item,
                      inactivityThresholdDays: inactivityDays,
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
                          if (context.mounted) {
                            showItemActionError(context, error);
                          }
                        }
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('Failed to load items:\n$err'),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'temp_select',
        onPressed: () => setState(() {
          _selectionMode = !_selectionMode;
          _selectedIds.clear();
        }),
        tooltip: _selectionMode ? 'Exit selection' : 'Select items',
        child: Icon(_selectionMode ? Icons.close : Icons.checklist),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.done_all,
              size: 80,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No temporary items yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Everything is clean and organized!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipWidget extends ConsumerWidget {
  final String label;
  final ItemFilter value;
  final ItemFilter currentValue;

  const _FilterChipWidget({
    required this.label,
    required this.value,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChoiceChip(
      label: Text(label),
      selected: currentValue == value,
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showCheckmark: false,
      side: BorderSide(
        color: currentValue == value
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).dividerColor,
      ),
      labelStyle: TextStyle(
        color: currentValue == value
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (selected) {
        if (selected) {
          ref.read(itemFilterProvider.notifier).state = value;
        }
      },
    );
  }
}
