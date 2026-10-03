import 'dart:developer' as developer;
import 'package:drift/drift.dart' as drift;
import 'dart:io';

import 'package:free_space/data/database/app_database.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/data/services/system_file_scan_service.dart';

/// Repository for managing tracked items.
class ItemRepository {
  Future<List<TrackedItemModel>> getAllItems() async {
    final rows = await _dao.select(_dao.trackedItems).get();
    return rows.map((r) => TrackedItemModel.fromDbRow(r)).toList();
  }

  final TrackedItemsDao _dao;
  final Future<Map<String, String?>> Function(List<String>)? _moveToSystemTrash;
  final Future<Set<String>> Function(List<String>)? _deleteFromSystemTrash;
  final Future<bool> Function()? _hasAllFilesAccess;
  final SystemFileScanService? _systemFileScanService;

  const ItemRepository(
    this._dao, {
    Future<Map<String, String?>> Function(List<String>)? moveToSystemTrash,
    Future<Set<String>> Function(List<String>)? deleteFromSystemTrash,
    Future<bool> Function()? hasAllFilesAccess,
    SystemFileScanService? systemFileScanService,
  })  : _moveToSystemTrash = moveToSystemTrash,
        _deleteFromSystemTrash = deleteFromSystemTrash,
        _hasAllFilesAccess = hasAllFilesAccess,
        _systemFileScanService = systemFileScanService;

  /// Watches all temporary items.
  Stream<List<TrackedItemModel>> watchTemporaryItems() {
    return _dao.watchByCategory(ItemCategory.temporary.name).map(
          (rows) => rows.map((r) => TrackedItemModel.fromDbRow(r)).toList(),
        );
  }

  Future<List<TrackedItemModel>> getPermanentItemsPage({
    required ItemType? type,
    required ItemSort sort,
    required String search,
    required int limit,
    required int offset,
    String? rootPath,
  }) async {
    final rows = await _dao.getItemsPage(
      category: ItemCategory.permanent,
      type: type,
      sort: sort,
      search: search,
      limit: limit,
      offset: offset,
      rootPath: rootPath,
    );
    return rows.map(TrackedItemModel.fromDbRow).toList();
  }

  /// Watches all binned items.
  Stream<List<TrackedItemModel>> watchBinnedItems() {
    return _dao.watchByCategory(ItemCategory.binned.name).map(
          (rows) => rows.map((r) => TrackedItemModel.fromDbRow(r)).toList(),
        );
  }

  /// Watches temporary items count.
  Stream<int> watchTemporaryCount() {
    return _dao.watchCountByCategory(ItemCategory.temporary.name);
  }

  /// Watches permanent items count.
  Stream<int> watchPermanentCountByRoot(String? rootPath) {
    return _dao.watchCountByCategory(ItemCategory.permanent.name,
        rootPath: rootPath);
  }

  /// Watches binned items count.
  Stream<int> watchBinnedCount() {
    return _dao.watchCountByCategory(ItemCategory.binned.name);
  }

  /// Adds a new tracked item to the database.
  Future<void> addItem(TrackedItemModel item) async {
    final trackedItem =
        item.category == ItemCategory.temporary && item.temporarySince == null
            ? item.copyWith(temporarySince: DateTime.now())
            : item;
    await _dao.insertItem(trackedItem.toCompanion());
  }

  /// Adds newly discovered filesystem items without changing existing categories.
  Future<void> addDiscoveredItems(List<TrackedItemModel> items) {
    return _dao.upsertDiscoveredItems(
      items.map((item) => item.toCompanion()).toList(),
    );
  }

  Future<int> registerRestoredPaths(
    List<String> paths,
    ItemCategory category,
  ) async {
    if (category == ItemCategory.binned) {
      throw ArgumentError.value(category, 'category', 'Cannot restore to Bin.');
    }
    if (paths.isEmpty) return 0;
    final scanner = _systemFileScanService;
    if (scanner == null) {
      throw StateError(
          'File scanning is not available to register restored items.');
    }

    final discoveredPaths = <String>{};
    await scanner.scanPaths(
      paths,
      saveBatch: (items) async {
        discoveredPaths.addAll(items.map((item) => item.path));
        await addDiscoveredItems(items);
      },
    );
    final rows = await Future.wait(discoveredPaths.map(_dao.getByPath));
    final ids = rows.whereType<TrackedItem>().map((item) => item.id).toList();
    await categorizeMany(ids, category);
    return ids.length;
  }

  /// Categorizes an item.
  Future<void> categorize(int id, ItemCategory category) async {
    await _dao.updateCategories([id], category.name);
  }

  Future<void> categorizeMany(
    List<int> ids,
    ItemCategory category,
  ) {
    if (category == ItemCategory.binned) {
      throw StateError(
        'Use moveToBin so items are moved to system Trash first.',
      );
    }
    return _dao.updateCategories(
      ids,
      category.name,
      binnedAt: category == ItemCategory.binned ? DateTime.now() : null,
    );
  }

  Future<void> restoreFromSystemTrash(
    List<int> ids,
  ) {
    return _dao.updateCategories(ids, ItemCategory.temporary.name);
  }

  Future<void> moveItemsToBin(Map<int, String?> trashPaths) {
    return _dao.moveItemsToBin(trashPaths);
  }

  /// Moves an item to the bin.
  Future<void> moveToBin(int id) async {
    final moveToTrash = _moveToSystemTrash;
    if (moveToTrash == null) {
      throw StateError('System Trash is not available on this platform.');
    }
    final item = await _dao.getById(id);
    if (item == null) {
      throw StateError('Tracked item $id no longer exists.');
    }
    final moved = await moveToTrash([item.path]);
    if (!moved.containsKey(item.path)) {
      throw StateError('The system did not move ${item.path} to Trash.');
    }
    await _dao.moveItemsToBin({id: moved[item.path]});
  }

  /// Restores a binned item to the temporary category.
  Future<void> restore(int id) async {
    await categorizeMany([id], ItemCategory.temporary);
  }

  /// Updates the last used timestamp for an item.
  Future<void> updateLastUsed(int id, DateTime lastUsed) async {
    await _dao.updateLastUsed(id, lastUsed);
  }

  /// Permanently deletes an item from the database.
  Future<void> deletePermanently(int id) async {
    final item = await _dao.getById(id);
    if (item == null) return;
    if (item.category == ItemCategory.binned) {
      await _permanentlyDeleteBinnedItems([
        TrackedItemModel.fromDbRow(item),
      ]);
    } else {
      await _dao.deleteItem(id);
    }
  }

  Future<void> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return;
    final rows = await Future.wait(ids.map(_dao.getById));
    final items =
        rows.whereType<TrackedItem>().map(TrackedItemModel.fromDbRow).toList();
    final binnedItems =
        items.where((item) => item.category == ItemCategory.binned).toList();
    if (binnedItems.isNotEmpty) {
      await _permanentlyDeleteBinnedItems(binnedItems);
    }
    final binnedIds = binnedItems.map((item) => item.id).toSet();
    final nonBinnedIds = ids.where((id) => !binnedIds.contains(id)).toList();
    if (nonBinnedIds.isNotEmpty) {
      await _dao.deleteItems(nonBinnedIds);

      int bytesSaved = 0;
      for (final item in items.where((i) => nonBinnedIds.contains(i.id))) {
        bytesSaved += item.sizeBytes;
      }
      if (bytesSaved > 0) {
        await (_dao.attachedDatabase as AppDatabase)
            .appSettingsDao
            .addSpaceSaved(bytesSaved);
      }
      try {
        await _dao.vacuumDatabase();
      } catch (_) {}
    }
  }

  /// Empties the bin.
  Future<void> emptyBin() async {
    final binnedItems = (await _dao.getAllByCategory(ItemCategory.binned.name))
        .map(TrackedItemModel.fromDbRow)
        .toList();
    await _permanentlyDeleteBinnedItems(binnedItems);
  }

  Future<int> purgeExpiredBinItems(int retentionDays) async {
    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    final expiredItems = (await _dao.getAllByCategory(ItemCategory.binned.name))
        .map(TrackedItemModel.fromDbRow)
        .where(
            (item) => item.binnedAt != null && !item.binnedAt!.isAfter(cutoff))
        .toList();
    if (expiredItems.isEmpty) return 0;
    final itemsWithTrashLocation =
        expiredItems.where((item) => item.systemTrashPath != null).toList();
    final deletedCount =
        await _permanentlyDeleteBinnedItems(itemsWithTrashLocation);
    if (itemsWithTrashLocation.length != expiredItems.length) {
      throw StateError(
        'Some expired Bin items have no saved system Trash path; they were kept to avoid deleting the wrong file.',
      );
    }
    return deletedCount;
  }

  Future<int> _permanentlyDeleteBinnedItems(
    List<TrackedItemModel> items,
  ) async {
    if (items.isEmpty) return 0;
    final deleteFromTrash = _deleteFromSystemTrash;
    if (deleteFromTrash == null) {
      throw StateError(
        'Permanent deletion from system Trash is not available on this platform.',
      );
    }
    if (items.any((item) => item.systemTrashPath == null)) {
      throw StateError(
        'Some Bin items have no saved system Trash path; they were kept to avoid deleting the wrong file.',
      );
    }

    final paths = items
        .map((item) =>
            item.systemTrashPath ??
            (throw StateError('A Bin item is missing its system Trash path.')))
        .toList();
    final deletedPaths = await deleteFromTrash(paths);
    final deletedItems =
        items.where((item) => deletedPaths.contains(item.systemTrashPath));
    final deletedItemList = deletedItems.toList();
    await _dao.deleteItems(deletedItemList.map((item) => item.id).toList());

    // Add space saved
    int bytesSaved = 0;
    for (final item in deletedItemList) {
      bytesSaved += item.sizeBytes;
    }
    if (bytesSaved > 0) {
      await (_dao.attachedDatabase as AppDatabase)
          .appSettingsDao
          .addSpaceSaved(bytesSaved);
    }

    // Compact the SQLite database after bulk deletions to free storage space
    if (deletedItemList.isNotEmpty) {
      try {
        await _dao.vacuumDatabase();
      } catch (_) {}
    }

    if (deletedPaths.length != paths.length) {
      throw StateError(
        'Only ${deletedPaths.length} of ${paths.length} items were permanently deleted. Items not confirmed by the system remain in Bin.',
      );
    }
    return deletedItemList.length;
  }

  /// Moves unused Permanent items into Temporary after the configured period.
  Future<int> moveInactivePermanentItemsToTemporary(int inactivityDays) async {
    final eligibleItems = await _dao.getInactivePermanentItems(inactivityDays);
    if (eligibleItems.isEmpty) return 0;
    await _dao.updateCategories(
      eligibleItems.map((item) => item.id).toList(),
      ItemCategory.temporary.name,
    );
    return eligibleItems.length;
  }

  /// Moves Temporary items into system Trash after their countdown expires.
  Future<int> autoBinInactiveItems(int inactivityDays) async {
    var eligibleItems = await _dao.getExpiredTemporaryItems(inactivityDays);
    if (eligibleItems.isEmpty) return 0;
    if (Platform.isAndroid &&
        eligibleItems.any((item) => item.type != ItemType.media) &&
        !await (_hasAllFilesAccess?.call() ?? Future.value(false))) {
      eligibleItems =
          eligibleItems.where((item) => item.type == ItemType.media).toList();
      if (eligibleItems.isEmpty) return 0;
    }
    final moveToTrash = _moveToSystemTrash;
    if (moveToTrash == null) {
      throw StateError('System Trash is not available on this platform.');
    }

    final moved =
        await moveToTrash(eligibleItems.map((item) => item.path).toList());
    final movedItems =
        eligibleItems.where((item) => moved.containsKey(item.path)).toList();
    await _dao.moveItemsToBin({
      for (final item in movedItems) item.id: moved[item.path],
    });
    if (movedItems.length != eligibleItems.length) {
      throw StateError(
        'Only ${movedItems.length} of ${eligibleItems.length} inactive items were moved to system Trash.',
      );
    }
    return movedItems.length;
  }

  /// Retrieves items that are ready to be binned.
  Future<List<TrackedItemModel>> getReadyToBinItems(int inactivityDays) async {
    final expiredItems = await _dao.getExpiredTemporaryItems(inactivityDays);
    return expiredItems.map(TrackedItemModel.fromDbRow).toList();
  }

  Future<void> trackNewFile(
      String path, ItemCategory category, String name) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return;

      final stat = await file.stat();
      final type = _determineType(path);

      final item = TrackedItemsCompanion.insert(
        name: name,
        path: path,
        type: type,
        sizeBytes: drift.Value(stat.size),
        category: category,
        createdAt: DateTime.now(),
        lastUsedAt: DateTime.now(),
        temporarySince: drift.Value(
            category == ItemCategory.temporary ? DateTime.now() : null),
      );

      await _dao.insertItem(item);
    } catch (e) {
      developer.log('Error tracking new file: $e');
    }
  }

  ItemType _determineType(String path) {
    final ext = path.split('.').last.toLowerCase();
    if ([
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'mp4',
      'mkv',
      'avi',
      'mov',
      'mp3',
      'wav',
      'aac',
      'flac'
    ].contains(ext)) {
      return ItemType.media;
    }
    if (['apk', 'aab'].contains(ext)) {
      return ItemType.app;
    }
    return ItemType.file;
  }
}
