import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/data/repositories/item_repository.dart';
import 'package:free_space/presentation/providers/database_provider.dart';
import 'package:free_space/presentation/providers/storage_provider.dart';
import 'package:free_space/data/services/system_file_scan_service.dart';
import 'package:free_space/data/services/native_platform_service.dart';

/// Filter options for items
enum ItemFilter {
  all,
  media,
  files,
  apps,
}

/// Provides the ItemRepository
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final dao = ref.watch(trackedItemsDaoProvider);
  final nativeService = ref.watch(nativePlatformServiceProvider);
  return ItemRepository(
    dao,
    moveToSystemTrash: nativeService.moveItemsToSystemTrash,
    deleteFromSystemTrash: nativeService.permanentlyDeleteItemsFromSystemTrash,
    hasAllFilesAccess: nativeService.hasAllFilesAccess,
    systemFileScanService: ref.watch(systemFileScanServiceProvider),
  );
});

final systemFileScanServiceProvider = Provider<SystemFileScanService>((ref) {
  return SystemFileScanService(
    nativePlatformService: ref.watch(nativePlatformServiceProvider),
  );
});

final systemScanProgressProvider = StateProvider<int?>((ref) => null);
final permanentItemsRevisionProvider = StateProvider<int>((ref) => 0);

const permanentItemsPageSize = 50;

class PermanentItemsPageQuery {
  final ItemFilter filter;
  final ItemSort sort;
  final String search;
  final int offset;
  final String? rootPath;

  const PermanentItemsPageQuery({
    required this.filter,
    required this.sort,
    required this.search,
    required this.offset,
    this.rootPath,
  });

  @override
  bool operator ==(Object other) =>
      other is PermanentItemsPageQuery &&
      other.filter == filter &&
      other.sort == sort &&
      other.search == search &&
      other.offset == offset &&
      other.rootPath == rootPath;

  @override
  int get hashCode => Object.hash(filter, sort, search, offset, rootPath);
}

final permanentItemsPageProvider =
    FutureProvider.family<List<TrackedItemModel>, PermanentItemsPageQuery>(
  (ref, query) {
    if (query.offset == 0) {
      ref.watch(permanentItemsRevisionProvider);
    }
    final type = switch (query.filter) {
      ItemFilter.all => null,
      ItemFilter.media => ItemType.media,
      ItemFilter.files => ItemType.file,
      ItemFilter.apps => ItemType.app,
    };
    return ref.watch(itemRepositoryProvider).getPermanentItemsPage(
          type: type,
          sort: query.sort,
          search: query.search,
          limit: permanentItemsPageSize,
          offset: query.offset,
          rootPath: query.rootPath,
        );
  },
);

final initialSystemScanProvider =
    FutureProvider<SystemScanResult?>((ref) async {
  final progressNotifier = ref.read(systemScanProgressProvider.notifier);
  final nativeService = ref.watch(nativePlatformServiceProvider);
  final root =
      await nativeService.getScanRoot() ?? await nativeService.selectScanRoot();
  if (root == null) return null;

  const scanRootKey = 'initial_system_scan_root';
  final settingsDao = ref.watch(appSettingsDaoProvider);
  if (await settingsDao.getSetting(scanRootKey) == root) return null;

  final repository = ref.watch(itemRepositoryProvider);
  progressNotifier.state = 0;
  try {
    final ignoredPaths = await settingsDao.getIgnoredPaths();
    final result = await ref.watch(systemFileScanServiceProvider).scan(
      root,
      ignoredPaths: ignoredPaths,
      saveBatch: repository.addDiscoveredItems,
      onProgress: (count) {
        progressNotifier.state = count;
        ref.read(permanentItemsRevisionProvider.notifier).state++;
      },
    );
    await settingsDao.setSetting(scanRootKey, root);
    return result;
  } finally {
    progressNotifier.state = null;
  }
});

/// Watches temporary items
final temporaryItemsProvider = StreamProvider<List<TrackedItemModel>>((ref) {
  return ref.watch(itemRepositoryProvider).watchTemporaryItems();
});

/// Watches binned items
final binnedItemsProvider = StreamProvider<List<TrackedItemModel>>((ref) {
  return ref.watch(itemRepositoryProvider).watchBinnedItems();
});

final systemTrashItemsProvider = FutureProvider<List<SystemTrashItem>>((ref) {
  return ref.watch(nativePlatformServiceProvider).listSystemTrashItems();
});

/// Watches temporary items count
final temporaryCountProvider = StreamProvider<int>((ref) {
  return ref.watch(itemRepositoryProvider).watchTemporaryCount();
});

/// Watches permanent items count
final permanentCountProvider = StreamProvider<int>((ref) {
  final rootPath = ref.watch(authorizedScanRootPathProvider).valueOrNull;
  return ref.watch(itemRepositoryProvider).watchPermanentCountByRoot(rootPath);
});

/// Watches binned items count
final binnedCountProvider = StreamProvider<int>((ref) {
  return ref.watch(itemRepositoryProvider).watchBinnedCount();
});

/// Current item filter
final itemFilterProvider = StateProvider<ItemFilter>((ref) {
  return ItemFilter.all;
});

/// Current item sort
final itemSortProvider = StateProvider<ItemSort>((ref) {
  return ItemSort.daysUnused;
});

/// Provides filtered and sorted temporary items
final filteredTemporaryItemsProvider = Provider<List<TrackedItemModel>>((ref) {
  final filter = ref.watch(itemFilterProvider);
  final sort = ref.watch(itemSortProvider);
  final itemsAsync = ref.watch(temporaryItemsProvider);

  return itemsAsync.when(
    data: (items) {
      // 1. Filter
      var filtered = items;
      if (filter != ItemFilter.all) {
        filtered = items.where((item) {
          if (filter == ItemFilter.media) return item.type == ItemType.media;
          if (filter == ItemFilter.files) return item.type == ItemType.file;
          if (filter == ItemFilter.apps) return item.type == ItemType.app;
          return true;
        }).toList();
      } else {
        filtered = List.from(items);
      }

      // 2. Sort
      filtered.sort((a, b) {
        switch (sort) {
          case ItemSort.daysUnused:
            return b.daysUnused.compareTo(a.daysUnused);
          case ItemSort.size:
            return b.sizeBytes.compareTo(a.sizeBytes);
          case ItemSort.name:
            return a.name.compareTo(b.name);
        }
      });

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
