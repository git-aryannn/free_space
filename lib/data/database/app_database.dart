import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:free_space/data/database/tables/app_settings.dart';
import 'package:free_space/data/database/tables/tracked_items.dart';
import 'package:free_space/data/models/item_enums.dart';

part 'app_database.g.dart';

/// The main application database class.
@DriftDatabase(
  tables: [TrackedItems, AppSettingsTable],
  daos: [TrackedItemsDao, AppSettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          await _createTrackedItemIndexes();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 3) {
            await migrator.addColumn(
                trackedItems, trackedItems.systemTrashPath);
          }
          if (from < 4) {
            await migrator.addColumn(trackedItems, trackedItems.temporarySince);
            await (update(trackedItems)
                  ..where(
                    (row) => row.category.equals(ItemCategory.temporary.name),
                  ))
                .write(
              TrackedItemsCompanion(temporarySince: Value(DateTime.now())),
            );
          }
          if (from < 5) {
            await migrator.createTable(appSettingsTable);
          }
          await _createTrackedItemIndexes();
        },
      );

  Future<void> _createTrackedItemIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS tracked_items_category_last_used_idx '
      'ON tracked_items (category, last_used_at, id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS tracked_items_category_type_last_used_idx '
      'ON tracked_items (category, type, last_used_at, id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS tracked_items_category_size_idx '
      'ON tracked_items (category, size_bytes DESC, id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS tracked_items_category_name_idx '
      'ON tracked_items (category, name, id)',
    );
  }
}

/// DAO for interacting with tracked items.
@DriftAccessor(tables: [TrackedItems])
class TrackedItemsDao extends DatabaseAccessor<AppDatabase>
    with _$TrackedItemsDaoMixin {
  TrackedItemsDao(super.db);

  Future<List<TrackedItem>> getAllByCategory(String categoryName) {
    final category =
        ItemCategory.values.firstWhere((e) => e.name == categoryName);
    return (select(trackedItems)
          ..where((t) => t.category.equals(category.name)))
        .get();
  }

  Stream<List<TrackedItem>> watchByCategory(String categoryName) {
    final category =
        ItemCategory.values.firstWhere((e) => e.name == categoryName);
    return (select(trackedItems)
          ..where((t) => t.category.equals(category.name)))
        .watch();
  }

  Future<List<TrackedItem>> getItemsPage({
    required ItemCategory category,
    required ItemSort sort,
    required int limit,
    required int offset,
    ItemType? type,
    String? search,
    String? rootPath,
  }) {
    final normalizedSearch = search?.trim() ?? '';
    final query = select(trackedItems)
      ..where(
        (row) =>
            row.category.equals(category.name) &
            (type == null ? const Constant(true) : row.type.equals(type.name)) &
            (normalizedSearch.isEmpty
                ? const Constant(true)
                : row.name.contains(normalizedSearch)) &
            (rootPath == null || rootPath.isEmpty
                ? const Constant(true)
                : row.path.like('$rootPath%')),
      )
      ..orderBy([
        (row) => switch (sort) {
              ItemSort.daysUnused => OrderingTerm.asc(row.lastUsedAt),
              ItemSort.size => OrderingTerm.desc(row.sizeBytes),
              ItemSort.name => OrderingTerm.asc(row.name),
            },
        (row) => OrderingTerm.asc(row.id),
      ])
      ..limit(limit, offset: offset);
    return query.get();
  }

  Stream<List<TrackedItem>> watchFlaggedItems() =>
      (select(trackedItems)..where((t) => t.isFlagged.equals(true))).watch();

  Future<int> insertItem(TrackedItemsCompanion item) =>
      into(trackedItems).insert(item, mode: InsertMode.insertOrReplace);

  Future<void> upsertDiscoveredItems(List<TrackedItemsCompanion> items) async {
    if (items.isEmpty) return;
    await transaction(() async {
      final existingRows = await (select(trackedItems)
            ..where(
              (table) => table.path.isIn(
                items.map((item) => item.path.value),
              ),
            ))
          .get();
      final existingByPath = {
        for (final row in existingRows) row.path: row,
      };

      await batch((batch) {
        batch.insertAll(
          trackedItems,
          items,
          mode: InsertMode.insertOrIgnore,
        );
      });

      for (final item in items) {
        final existing = existingByPath[item.path.value];
        if (existing == null ||
            (existing.name == item.name.value &&
                existing.type == item.type.value &&
                existing.sizeBytes == item.sizeBytes.value &&
                existing.createdAt == item.createdAt.value &&
                existing.lastUsedAt == item.lastUsedAt.value)) {
          continue;
        }

        await (update(trackedItems)
              ..where((table) => table.path.equals(item.path.value)))
            .write(
          TrackedItemsCompanion(
            name: item.name,
            type: item.type,
            sizeBytes: item.sizeBytes,
            mimeType: item.mimeType,
            createdAt: item.createdAt,
            lastUsedAt: item.lastUsedAt,
          ),
        );
      }
    });
  }

  Future<bool> updateItem(TrackedItemsCompanion item) =>
      update(trackedItems).replace(item);

  Future<void> updateCategory(int id, String categoryName,
      {DateTime? binnedAt}) async {
    final category =
        ItemCategory.values.firstWhere((e) => e.name == categoryName);
    await (update(trackedItems)..where((t) => t.id.equals(id))).write(
      TrackedItemsCompanion(
        category: Value(category),
        binnedAt: Value(binnedAt),
        temporarySince: category == ItemCategory.temporary
            ? Value(DateTime.now())
            : const Value(null),
      ),
    );
  }

  Future<void> updateCategories(
    List<int> ids,
    String categoryName, {
    DateTime? binnedAt,
  }) async {
    if (ids.isEmpty) return;
    final category =
        ItemCategory.values.firstWhere((e) => e.name == categoryName);
    await (update(trackedItems)..where((row) => row.id.isIn(ids))).write(
      TrackedItemsCompanion(
        category: Value(category),
        binnedAt: Value(binnedAt),
        temporarySince: category == ItemCategory.temporary
            ? Value(DateTime.now())
            : const Value(null),
        systemTrashPath: const Value(null),
      ),
    );
  }

  Future<void> moveItemsToBin(Map<int, String?> trashPaths) async {
    if (trashPaths.isEmpty) return;
    await transaction(() async {
      for (final entry in trashPaths.entries) {
        await (update(trackedItems)..where((row) => row.id.equals(entry.key)))
            .write(
          TrackedItemsCompanion(
            category: const Value(ItemCategory.binned),
            binnedAt: Value(DateTime.now()),
            temporarySince: const Value(null),
            systemTrashPath: Value(entry.value),
          ),
        );
      }
    });
  }

  Future<void> updateLastUsed(int id, DateTime lastUsed) async {
    await (update(trackedItems)..where((t) => t.id.equals(id))).write(
      TrackedItemsCompanion(lastUsedAt: Value(lastUsed)),
    );
  }

  Future<void> flagForBin(int id) async {
    await (update(trackedItems)..where((t) => t.id.equals(id))).write(
      const TrackedItemsCompanion(isFlagged: Value(true)),
    );
  }

  Future<void> deleteItem(int id) =>
      (delete(trackedItems)..where((t) => t.id.equals(id))).go();

  Future<void> deleteItems(List<int> ids) async {
    if (ids.isEmpty) return;
    await (delete(trackedItems)..where((row) => row.id.isIn(ids))).go();
  }

  Future<void> deleteAllBinned() => (delete(trackedItems)
        ..where((t) => t.category.equals(ItemCategory.binned.name)))
      .go();

  Future<List<TrackedItem>> getInactivePermanentItems(int days) {
    final today = DateTime.now();
    final cutoffExclusive = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    return (select(trackedItems)
          ..where(
            (t) =>
                t.category.equals(ItemCategory.permanent.name) &
                t.lastUsedAt.isSmallerThanValue(cutoffExclusive),
          ))
        .get();
  }

  Future<List<TrackedItem>> getExpiredTemporaryItems(int days) {
    final today = DateTime.now();
    final cutoffExclusive = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    return (select(trackedItems)
          ..where(
            (t) =>
                t.category.equals(ItemCategory.temporary.name) &
                (t.temporarySince.isSmallerThanValue(cutoffExclusive) |
                    (t.temporarySince.isNull() &
                        t.lastUsedAt.isSmallerThanValue(cutoffExclusive))),
          ))
        .get();
  }

  Future<TrackedItem?> getByPath(String path) =>
      (select(trackedItems)..where((t) => t.path.equals(path)))
          .getSingleOrNull();

  Future<TrackedItem?> getById(int id) =>
      (select(trackedItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<int> watchCountByCategory(String categoryName, {String? rootPath}) {
    final category =
        ItemCategory.values.firstWhere((e) => e.name == categoryName);
    final count = trackedItems.id.count();
    final query = selectOnly(trackedItems)
      ..addColumns([count])
      ..where(trackedItems.category.equals(category.name) &
          (rootPath == null || rootPath.isEmpty
              ? const Constant(true)
              : trackedItems.path.like('$rootPath%')));
    return query.map((row) => row.read(count)!).watchSingle();
  }

  /// Compacts and defragments the database
  Future<void> vacuumDatabase() => customStatement('VACUUM');
}

/// DAO for interacting with app settings.
@DriftAccessor(tables: [AppSettingsTable])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettingsTable).insertOnConflictUpdate(
      AppSettingsTableData(key: key, value: value),
    );
  }

  Stream<String?> watchSetting(String key) {
    return (select(appSettingsTable)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<List<String>> getIgnoredPaths() async {
    final value = await getSetting('ignored_paths');
    if (value == null || value.isEmpty) return [];
    try {
      // Ensure dart:convert is imported at the top
      return List<String>.from(jsonDecode(value));
    } catch (_) {
      return [];
    }
  }

  Future<void> addIgnoredPath(String path) async {
    final paths = await getIgnoredPaths();
    if (!paths.contains(path)) {
      paths.add(path);

      await setSetting('ignored_paths', jsonEncode(paths));
    }
  }

  Future<int> getTotalSpaceSaved() async {
    final value = await getSetting('total_space_saved');
    return int.tryParse(value ?? '0') ?? 0;
  }

  Future<void> addSpaceSaved(int bytes) async {
    if (bytes <= 0) return;
    final current = await getTotalSpaceSaved();
    await setSetting('total_space_saved', (current + bytes).toString());
  }

  Future<void> removeIgnoredPath(String path) async {
    final paths = await getIgnoredPaths();
    if (paths.contains(path)) {
      paths.remove(path);

      await setSetting('ignored_paths', jsonEncode(paths));
    }
  }
}
