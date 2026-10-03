import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/presentation/providers/items_provider.dart';
import 'package:free_space/presentation/providers/storage_provider.dart';
import 'package:free_space/presentation/widgets/item_card.dart';
import 'package:free_space/presentation/widgets/item_action_helpers.dart';
import 'package:free_space/presentation/widgets/tracked_item_actions.dart';

enum _ScanTarget { downloads, anotherFolder, fullDevice }

/// Screen for displaying items marked as permanent.
class PermanentScreen extends ConsumerStatefulWidget {
  const PermanentScreen({super.key});

  @override
  ConsumerState<PermanentScreen> createState() => _PermanentScreenState();
}

class _PermanentScreenState extends ConsumerState<PermanentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearchExpanded = false;
  bool _isScanning = false;
  bool _selectingAll = false;
  bool _allItemsSelected = false;
  bool _selectionMode = false;
  bool _showPermanentCount = false;
  Timer? _permanentCountTimer;
  final Set<int> _selectedIds = {};
  final Map<int, TrackedItemModel> _selectedItems = {};
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _permanentCountTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _revealPermanentCount(int count) {
    _permanentCountTimer?.cancel();
    setState(() => _showPermanentCount = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('This folder contains $count items on your device'),
          duration: const Duration(seconds: 3),
        ),
      );
    _permanentCountTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showPermanentCount = false);
    });
  }

  Future<void> _moveSelected(ItemCategory category) async {
    try {
      await moveTrackedItems(
        context,
        ref,
        _selectedItems.values.toList(),
        category,
      );
      if (mounted) {
        setState(() {
          _selectedIds.clear();
          _selectedItems.clear();
          _selectionMode = false;
          _allItemsSelected = false;
        });
      }
    } catch (error) {
      if (mounted) showItemActionError(context, error);
    }
  }

  Future<void> _toggleSelectAll() async {
    if (_selectingAll) return;
    if (_allItemsSelected) {
      setState(() {
        _selectedIds.clear();
        _selectedItems.clear();
        _allItemsSelected = false;
      });
      return;
    }

    setState(() {
      _selectionMode = true;
      _selectingAll = true;
    });
    try {
      final filter = ref.read(itemFilterProvider);
      final sort = ref.read(itemSortProvider);
      final type = switch (filter) {
        ItemFilter.all => null,
        ItemFilter.media => ItemType.media,
        ItemFilter.files => ItemType.file,
        ItemFilter.apps => ItemType.app,
      };
      const batchSize = 1000;
      final allItems = <TrackedItemModel>[];
      var offset = 0;
      while (true) {
        final rootPath = ref.read(authorizedScanRootPathProvider).valueOrNull;
        final page =
            await ref.read(itemRepositoryProvider).getPermanentItemsPage(
                  type: type,
                  sort: sort,
                  search: _searchQuery,
                  limit: batchSize,
                  offset: offset,
                  rootPath: rootPath,
                );
        allItems.addAll(page);
        if (page.length < batchSize) break;
        offset += page.length;
      }
      if (!mounted) return;
      setState(() {
        _selectedIds
          ..clear()
          ..addAll(allItems.map((item) => item.id));
        _selectedItems
          ..clear()
          ..addEntries(allItems.map((item) => MapEntry(item.id, item)));
        _allItemsSelected = true;
      });
    } catch (error) {
      if (mounted) showItemActionError(context, error);
    } finally {
      if (mounted) setState(() => _selectingAll = false);
    }
  }

  void _toggleSelection(TrackedItemModel item) {
    setState(() {
      if (!_selectionMode) _selectionMode = true;
      _allItemsSelected = false;
      if (!_selectedIds.add(item.id)) {
        _selectedIds.remove(item.id);
        _selectedItems.remove(item.id);
      } else {
        _selectedItems[item.id] = item;
      }
    });
  }

  Future<void> _showItemActions(TrackedItemModel item) {
    return showTrackedItemActions(
      context,
      item: item,
      onMove: (category) => moveTrackedItem(context, ref, item, category),
      onDelete: () => deleteTrackedItem(context, ref, item),
      onReveal: () => revealTrackedItem(ref, item),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(initialSystemScanProvider, (_, next) {
      if (next.hasValue) ref.invalidate(authorizedScanRootPathProvider);
    });
    final permCountAsync = ref.watch(permanentCountProvider);
    final currentFilter = ref.watch(itemFilterProvider);
    final currentSort = ref.watch(itemSortProvider);
    final initialScanAsync = ref.watch(initialSystemScanProvider);
    final discoveredItems = ref.watch(systemScanProgressProvider);
    final selectedFolderPath = ref.watch(authorizedScanRootPathProvider);
    final scanning = _isScanning || initialScanAsync.isLoading;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            toolbarHeight: 68,
            floating: true,
            snap: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permanent Storage',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  selectedFolderPath.valueOrNull ??
                      'Internal Storage (Full Device Access)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            actions: [
              if (_selectionMode)
                TextButton(
                  onPressed: _selectingAll ? null : _toggleSelectAll,
                  child: _selectingAll
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _allItemsSelected ? 'Deselect all' : 'Select all',
                        ),
                ),
              if (_selectionMode)
                PopupMenuButton<ItemCategory>(
                  tooltip: 'Move selected items',
                  icon: const Icon(Icons.drive_file_move),
                  onSelected: _moveSelected,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: ItemCategory.temporary,
                      child: Text('Move to Temporary'),
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
                    _selectedItems.clear();
                    _allItemsSelected = false;
                  }),
                  child: Text('Cancel (${_selectedIds.length})'),
                ),
              IconButton(
                tooltip: 'Choose a folder to scan',
                onPressed: scanning ? null : _scanDevice,
                icon: scanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.folder_open),
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Tooltip(
                    message:
                        'This folder contains ${permCountAsync.valueOrNull ?? 0} items on your device',
                    showDuration: const Duration(seconds: 3),
                    child: IconButton(
                      onPressed: () => _revealPermanentCount(
                        permCountAsync.valueOrNull ?? 0,
                      ),
                      icon: const Icon(Icons.lock_outline),
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(49.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: _isSearchExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                setState(() {
                                  _isSearchExpanded = true;
                                });
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  _searchFocusNode.requestFocus();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
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
                      secondChild: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search permanent items...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _isSearchExpanded = false;
                                });
                              },
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            if (scanning) ...[
              const LinearProgressIndicator(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Scanning accessible folders${discoveredItems == null ? '' : ' · $discoveredItems items found'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
            if (initialScanAsync.hasError)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Automatic scan failed: ${initialScanAsync.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: _PermanentItemsPagedList(
                key: ValueKey(
                  '${currentFilter.name}|${currentSort.name}|$_searchQuery|${selectedFolderPath.valueOrNull}',
                ),
                query: PermanentItemsPageQuery(
                  filter: currentFilter,
                  sort: currentSort,
                  search: _searchQuery,
                  offset: 0,
                  rootPath: selectedFolderPath.valueOrNull,
                ),
                scanning: scanning,
                onScan: _scanDevice,
                selectionMode: _selectionMode,
                selectedIds: _selectedIds,
                onSelect: _toggleSelection,
                onActions: _showItemActions,
                onReveal: (item) async {
                  try {
                    await revealTrackedItem(ref, item);
                  } catch (error) {
                    if (context.mounted) showItemActionError(context, error);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () => setState(() {
              _selectionMode = !_selectionMode;
              _selectedIds.clear();
              _selectedItems.clear();
              _allItemsSelected = false;
            }),
            tooltip: _selectionMode ? 'Exit selection' : 'Select items',
            child: Icon(_selectionMode ? Icons.close : Icons.checklist),
          ),
        ],
      ),
    );
  }

  Future<void> _scanDevice() async {
    setState(() => _isScanning = true);
    try {
      final nativeService = ref.read(nativePlatformServiceProvider);
      final scanTarget = Theme.of(context).platform == TargetPlatform.android
          ? await _chooseScanTarget()
          : _ScanTarget.anotherFolder;
      if (!mounted || scanTarget == null) return;

      final List<String>? paths;
      if (scanTarget == _ScanTarget.downloads ||
          scanTarget == _ScanTarget.fullDevice) {
        final hasAccess = await nativeService.requestAllFilesAccess();
        if (!mounted) return;
        if (!hasAccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access was not granted. No files were scanned.'),
            ),
          );
          return;
        }

        if (scanTarget == _ScanTarget.fullDevice) {
          final rootPath = await nativeService.getExternalStorageRootPath();
          await nativeService.setScanRoot(rootPath);
          paths = [rootPath];
        } else {
          final downloadsPath = await nativeService.getDownloadsPath();
          await nativeService.setScanRoot(downloadsPath);
          paths = [downloadsPath];
        }
      } else {
        paths = await nativeService.selectScanItems();
        if (paths != null && paths.isNotEmpty) {
          // File writes
          try {
            final f = await ref.read(nativePlatformServiceProvider).getDownloadsPath();
          } catch(e) {}
          await nativeService.setScanRoot(paths.first);
        }
      }
      print("DEBUG: paths from selectScanItems: $paths");
      if (!mounted) return;
      ref.invalidate(authorizedScanRootPathProvider);
      final newRoot = await ref.read(nativePlatformServiceProvider).getScanRootDisplayPath();
      print("DEBUG: newRoot after invalidate: $newRoot");
      if (paths == null || paths.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No files or folders were selected.')),
        );
        return;
      }

      final repository = ref.read(itemRepositoryProvider);
      ref.read(systemScanProgressProvider.notifier).state = 0;
      final result = await ref.read(systemFileScanServiceProvider).scanPaths(
        paths,
        saveBatch: repository.addDiscoveredItems,
        onProgress: (count) {
          ref.read(systemScanProgressProvider.notifier).state = count;
          ref.read(permanentItemsRevisionProvider.notifier).state++;
        },
      );
      if (!mounted) return;

      final skippedMessage = result.inaccessibleDirectories == 0
          ? ''
          : ' ${result.inaccessibleDirectories} inaccessible folders were skipped.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Scanned ${result.discoveredItems} items.$skippedMessage'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not scan the selected items: $error')),
      );
    } finally {
      ref.read(systemScanProgressProvider.notifier).state = null;
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<_ScanTarget?> _chooseScanTarget() {
    return showModalBottomSheet<_ScanTarget>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Choose a folder to scan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Scan Downloads'),
              subtitle: const Text('Scan all items in the Downloads folder'),
              onTap: () => Navigator.pop(context, _ScanTarget.downloads),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Other Folder'),
              subtitle: const Text('Pick any specific folder to scan'),
              onTap: () => Navigator.pop(context, _ScanTarget.anotherFolder),
            ),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text('Scan Full Device'),
              subtitle: const Text(
                  'Scan all files, media, and apps (Requires permission)'),
              onTap: () => Navigator.pop(context, _ScanTarget.fullDevice),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermanentItemsPagedList extends ConsumerStatefulWidget {
  final PermanentItemsPageQuery query;
  final bool scanning;
  final VoidCallback onScan;
  final bool selectionMode;
  final Set<int> selectedIds;
  final ValueChanged<TrackedItemModel> onSelect;
  final ValueChanged<TrackedItemModel> onActions;
  final ValueChanged<TrackedItemModel> onReveal;

  const _PermanentItemsPagedList({
    super.key,
    required this.query,
    required this.scanning,
    required this.onScan,
    required this.selectionMode,
    required this.selectedIds,
    required this.onSelect,
    required this.onActions,
    required this.onReveal,
  });

  @override
  ConsumerState<_PermanentItemsPagedList> createState() =>
      _PermanentItemsPagedListState();
}

class _PermanentItemsPagedListState
    extends ConsumerState<_PermanentItemsPagedList> {
  ScrollController? _scrollController;
  int _loadedPageCount = 1;
  bool _loadingMore = false;
  bool _hasMore = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController?.removeListener(_maybeLoadNextPage);
    _scrollController = PrimaryScrollController.maybeOf(context);
    _scrollController?.addListener(_maybeLoadNextPage);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_maybeLoadNextPage);
    super.dispose();
  }

  void _maybeLoadNextPage() {
    if (!(_scrollController?.hasClients ?? false) ||
        !_hasMore ||
        _loadingMore ||
        (_scrollController?.position.extentAfter ?? 0) > 500) {
      return;
    }
    setState(() {
      _loadedPageCount++;
      _loadingMore = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rootPath = ref.watch(authorizedScanRootPathProvider).valueOrNull;
    final pages = List.generate(_loadedPageCount, (index) {
      return ref.watch(
        permanentItemsPageProvider(
          PermanentItemsPageQuery(
            filter: widget.query.filter,
            sort: widget.query.sort,
            search: widget.query.search,
            offset: index * permanentItemsPageSize,
            rootPath: rootPath,
          ),
        ),
      );
    });
    final items = pages
        .expand((page) => page.valueOrNull ?? const <TrackedItemModel>[])
        .toList();
    final firstPage = pages.first;
    final lastPage = pages.last;
    _hasMore = lastPage.valueOrNull?.length == permanentItemsPageSize;

    if (_loadingMore && (lastPage.hasValue || lastPage.hasError)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _loadingMore = false);
      });
    }

    if (firstPage.isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (firstPage.hasError && items.isEmpty) {
      return Center(
          child: Text('Failed to load permanent items: ${firstPage.error}'));
    }
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No permanent items found.'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: widget.scanning ? null : widget.onScan,
                icon: const Icon(Icons.folder_open),
                label: const Text('Select folder and scan'),
              ),
            ],
          ),
        ),
      );
    }

    return Scrollbar(
      interactive: true,
      thickness: 6.0,
      radius: const Radius.circular(10),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: items.length + (_hasMore || _loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            if (lastPage.hasError) {
              return TextButton(
                onPressed: () {
                  final offset =
                      (_loadedPageCount - 1) * permanentItemsPageSize;
                  ref.invalidate(
                    permanentItemsPageProvider(
                      PermanentItemsPageQuery(
                        filter: widget.query.filter,
                        sort: widget.query.sort,
                        search: widget.query.search,
                        offset: offset,
                        rootPath: rootPath,
                      ),
                    ),
                  );
                  setState(() => _loadingMore = true);
                },
                child: const Text('Retry loading more'),
              );
            }
            if (!_loadingMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Scroll to load more items'),
                ),
              );
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final item = items[index];
          return ItemCard(
            item: item,
            selectionMode: widget.selectionMode,
            selected: widget.selectedIds.contains(item.id),
            onTap: widget.selectionMode
                ? () => widget.onSelect(item)
                : () => widget.onActions(item),
            onLongPress: () => widget.onSelect(item),
            onDoubleTap: () => widget.onReveal(item),
          );
        },
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
