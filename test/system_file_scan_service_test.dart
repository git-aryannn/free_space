import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_space/data/database/app_database.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/data/repositories/item_repository.dart';
import 'package:free_space/data/services/system_file_scan_service.dart';
import 'package:free_space/data/services/native_platform_service.dart';
import 'package:free_space/presentation/providers/database_provider.dart';
import 'package:free_space/presentation/providers/items_provider.dart';

void main() {
  test('discovers files, media, and app bundles as permanent items', () async {
    final root = await Directory.systemTemp.createTemp('free-space-scan-');
    addTearDown(() => root.delete(recursive: true));
    await File('${root.path}/report.pdf').writeAsString('report');
    await File('${root.path}/photo.jpg').writeAsString('photo');
    final appContents = await Directory('${root.path}/Sample.app/Contents')
        .create(recursive: true);
    await File('${appContents.path}/Info.plist').writeAsString('app');

    final items = <TrackedItemModel>[];
    final result = await SystemFileScanService().scan(
      root.path,
      saveBatch: (batch) async => items.addAll(batch),
    );

    expect(result.discoveredItems, 3);
    expect(items, hasLength(3));
    expect(
      items.singleWhere((item) => item.name == 'photo.jpg').type,
      ItemType.media,
    );
    expect(
      items.singleWhere((item) => item.name == 'report.pdf').type,
      ItemType.file,
    );
    final app = items.singleWhere((item) => item.name == 'Sample.app');
    expect(app.type, ItemType.app);
    expect(app.sizeBytes, greaterThan(0));
    expect(
      items.every((item) => item.category == ItemCategory.permanent),
      isTrue,
    );
    expect(items.every((item) => item.daysUnused >= 0), isTrue);
  });

  test('scans only specifically selected files and folders', () async {
    final root = await Directory.systemTemp.createTemp('free-space-selected-');
    addTearDown(() => root.delete(recursive: true));
    final folder =
        await Directory('${root.path}/selected-folder').create(recursive: true);
    final selectedFile =
        await File('${root.path}/selected.pdf').writeAsString('selected');
    await File('${root.path}/not-selected.txt').writeAsString('ignored');
    await File('${folder.path}/inside.txt').writeAsString('inside');

    final items = <TrackedItemModel>[];
    final result = await SystemFileScanService().scanPaths(
      [selectedFile.path, folder.path],
      saveBatch: (batch) async => items.addAll(batch),
    );

    expect(result.discoveredItems, 2);
    expect(
        items.map((item) => item.name).toSet(), {'selected.pdf', 'inside.txt'});
    expect(items.any((item) => item.name == 'not-selected.txt'), isFalse);
  });

  test('scans Android SAF folder selections through the native bridge',
      () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('com.freespace.app/platform');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'scanDocumentTree');
      return {
        'items': [
          {
            'name': 'photo.jpg',
            'path': '/storage/emulated/0/Pictures/photo.jpg',
            'sizeBytes': 42,
            'lastModified': 1700000000000,
          },
        ],
        'inaccessibleDirectories': 1,
      };
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    final items = <TrackedItemModel>[];
    final result = await SystemFileScanService(
      nativePlatformService: NativePlatformService(),
    ).scanPaths(
      ['content://com.android.externalstorage.documents/tree/primary%3APictures'],
      saveBatch: (batch) async => items.addAll(batch),
    );

    expect(result.discoveredItems, 1);
    expect(result.inaccessibleDirectories, 1);
    expect(items.single.name, 'photo.jpg');
    expect(items.single.type, ItemType.media);
    expect(items.single.sizeBytes, 42);
  });

  test('requests Downloads access through Android and resolves its path',
      () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('com.freespace.app/platform');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      return switch (call.method) {
        'requestAllFilesAccess' => true,
        'getDownloadsPath' => '/storage/emulated/0/Download',
        _ => null,
      };
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    final nativeService = NativePlatformService();
    expect(await nativeService.requestAllFilesAccess(), isTrue);
    expect(
      await nativeService.getDownloadsPath(),
      '/storage/emulated/0/Download',
    );
  });

  test('saves and reports scan batches before the full scan completes',
      () async {
    final root = await Directory.systemTemp.createTemp('free-space-batches-');
    addTearDown(() => root.delete(recursive: true));
    for (var index = 0; index < 501; index++) {
      await File('${root.path}/file-$index.txt').writeAsString('file');
    }

    final progress = <int>[];
    final savedBatches = <int>[];
    await SystemFileScanService().scan(
      root.path,
      saveBatch: (batch) async => savedBatches.add(batch.length),
      onProgress: progress.add,
    );

    expect(savedBatches, [500, 1]);
    expect(progress, [500, 501]);
  });

  test('permanent item pages do not wait for initial scan completion',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        itemRepositoryProvider.overrideWith(
          (ref) => ItemRepository(database.trackedItemsDao),
        ),
      ],
    );
    addTearDown(container.dispose);
    final items = await container.read(
      permanentItemsPageProvider(
        const PermanentItemsPageQuery(
          filter: ItemFilter.all,
          sort: ItemSort.daysUnused,
          search: '',
          offset: 0,
        ),
      ).future,
    );
    expect(items, isEmpty);
  });

  test('refreshes discovered metadata without changing an existing category',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = ItemRepository(database.trackedItemsDao);
    final original = TrackedItemModel(
      id: 0,
      name: 'document.pdf',
      path: '/scan/document.pdf',
      type: ItemType.file,
      sizeBytes: 10,
      category: ItemCategory.temporary,
      createdAt: DateTime(2024),
      lastUsedAt: DateTime(2024),
      isFlagged: false,
    );
    await repository.addItem(original);

    await repository.addDiscoveredItems([
      original.copyWith(
        sizeBytes: 20,
        category: ItemCategory.permanent,
        lastUsedAt: DateTime(2025),
      ),
    ]);

    final refreshed = await database.trackedItemsDao
        .getAllByCategory(ItemCategory.temporary.name);
    expect(refreshed, hasLength(1));
    expect(refreshed.single.sizeBytes, 20);
    expect(refreshed.single.lastUsedAt, DateTime(2025));
    expect(
      await database.trackedItemsDao
          .getAllByCategory(ItemCategory.permanent.name),
      isEmpty,
    );
  });

  test('permanently deletes expired bin entries only after system confirmation',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final deletedSystemPaths = <String>[];
    final repository = ItemRepository(
      database.trackedItemsDao,
      deleteFromSystemTrash: (paths) async {
        deletedSystemPaths.addAll(paths);
        return paths.toSet();
      },
    );
    final now = DateTime.now();
    for (final item in [
      TrackedItemModel(
        id: 0,
        name: 'expired.txt',
        path: '/documents/expired.txt',
        type: ItemType.file,
        sizeBytes: 10,
        category: ItemCategory.binned,
        createdAt: now.subtract(const Duration(days: 90)),
        lastUsedAt: now.subtract(const Duration(days: 60)),
        binnedAt: now.subtract(const Duration(days: 31)),
        systemTrashPath: '/.Trash/expired.txt',
        isFlagged: false,
      ),
      TrackedItemModel(
        id: 0,
        name: 'still-in-bin.txt',
        path: '/documents/still-in-bin.txt',
        type: ItemType.file,
        sizeBytes: 20,
        category: ItemCategory.binned,
        createdAt: now.subtract(const Duration(days: 60)),
        lastUsedAt: now.subtract(const Duration(days: 45)),
        binnedAt: now.subtract(const Duration(days: 29)),
        systemTrashPath: '/.Trash/still-in-bin.txt',
        isFlagged: false,
      ),
    ]) {
      await repository.addItem(item);
    }

    final purgedCount = await repository.purgeExpiredBinItems(30);

    expect(purgedCount, 1);
    expect(deletedSystemPaths, ['/.Trash/expired.txt']);
    final remaining = await database.trackedItemsDao
        .getAllByCategory(ItemCategory.binned.name);
    expect(remaining.map((item) => item.name), ['still-in-bin.txt']);
  });

  test('auto-bins temporary items when the inactivity threshold is reached',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final movedPaths = <String>[];
    final repository = ItemRepository(
      database.trackedItemsDao,
      moveToSystemTrash: (paths) async {
        movedPaths.addAll(paths);
        return {
          for (final path in paths) path: '/.Trash/${path.split('/').last}'
        };
      },
    );
    final now = DateTime.now();
    for (final age in [30, 29]) {
      await repository.addItem(
        TrackedItemModel(
          id: 0,
          name: 'file-$age.txt',
          path: '/documents/file-$age.txt',
          type: ItemType.file,
          sizeBytes: 10,
          category: ItemCategory.temporary,
          createdAt: now.subtract(Duration(days: age)),
          lastUsedAt: now.subtract(Duration(days: age)),
          temporarySince: now.subtract(Duration(days: age)),
          isFlagged: false,
        ),
      );
    }

    final movedCount = await repository.autoBinInactiveItems(30);

    expect(movedCount, 1);
    expect(movedPaths, ['/documents/file-30.txt']);
    final binned = await repository.watchBinnedItems().first;
    expect(binned.single.name, 'file-30.txt');
  });

  test('starts the inactivity countdown when an item moves to Temporary',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = ItemRepository(database.trackedItemsDao);
    final oldAccessDate = DateTime.now().subtract(const Duration(days: 60));
    await repository.addItem(
      TrackedItemModel(
        id: 0,
        name: 'recently-moved.txt',
        path: '/documents/recently-moved.txt',
        type: ItemType.file,
        sizeBytes: 10,
        category: ItemCategory.permanent,
        createdAt: oldAccessDate,
        lastUsedAt: oldAccessDate,
        isFlagged: false,
      ),
    );
    final item = await database.trackedItemsDao.getByPath(
      '/documents/recently-moved.txt',
    );
    await repository.categorizeMany([item!.id], ItemCategory.temporary);

    final temporary = (await repository.watchTemporaryItems().first).single;
    expect(temporary.temporarySince, isNotNull);
    expect(temporary.daysUntilBinned(30), 30);
    expect(await repository.autoBinInactiveItems(30), 0);
  });

  test('Auto-Bin moves unused Permanent items to Temporary after threshold',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = ItemRepository(database.trackedItemsDao);
    final now = DateTime.now();
    for (final age in [30, 29]) {
      await repository.addItem(
        TrackedItemModel(
          id: 0,
          name: 'permanent-$age.txt',
          path: '/documents/permanent-$age.txt',
          type: ItemType.file,
          sizeBytes: 10,
          category: ItemCategory.permanent,
          createdAt: now.subtract(Duration(days: age)),
          lastUsedAt: now.subtract(Duration(days: age)),
          isFlagged: false,
        ),
      );
    }

    final movedCount =
        await repository.moveInactivePermanentItemsToTemporary(30);

    expect(movedCount, 1);
    final temporary = await repository.watchTemporaryItems().first;
    expect(temporary.single.name, 'permanent-30.txt');
    expect(temporary.single.temporarySince, isNotNull);
    expect(temporary.single.daysUntilBinned(30), 30);
    expect(await repository.autoBinInactiveItems(30), 0);
  });

  test('queries permanent results in sorted, filtered pages', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = ItemRepository(database.trackedItemsDao);
    final now = DateTime.now();
    for (final item in [
      TrackedItemModel(
        id: 0,
        name: 'new-photo.jpg',
        path: '/scan/new-photo.jpg',
        type: ItemType.media,
        sizeBytes: 50,
        category: ItemCategory.permanent,
        createdAt: now,
        lastUsedAt: now,
        isFlagged: false,
      ),
      TrackedItemModel(
        id: 0,
        name: 'old-photo.jpg',
        path: '/scan/old-photo.jpg',
        type: ItemType.media,
        sizeBytes: 150,
        category: ItemCategory.permanent,
        createdAt: DateTime(2020),
        lastUsedAt: DateTime(2020),
        isFlagged: false,
      ),
      TrackedItemModel(
        id: 0,
        name: 'document.pdf',
        path: '/scan/document.pdf',
        type: ItemType.file,
        sizeBytes: 100,
        category: ItemCategory.permanent,
        createdAt: DateTime(2021),
        lastUsedAt: DateTime(2021),
        isFlagged: false,
      ),
    ]) {
      await repository.addItem(item);
    }

    final oldestFirst = await repository.getPermanentItemsPage(
      type: ItemType.media,
      sort: ItemSort.daysUnused,
      search: 'photo',
      limit: 1,
      offset: 0,
    );
    final nextPage = await repository.getPermanentItemsPage(
      type: ItemType.media,
      sort: ItemSort.daysUnused,
      search: 'photo',
      limit: 1,
      offset: 1,
    );
    final largestFirst = await repository.getPermanentItemsPage(
      type: null,
      sort: ItemSort.size,
      search: '',
      limit: 1,
      offset: 0,
    );

    expect(oldestFirst.single.name, 'old-photo.jpg');
    expect(nextPage.single.name, 'new-photo.jpg');
    expect(largestFirst.single.sizeBytes, 150);
    expect(
        await database.trackedItemsDao.watchCountByCategory('permanent').first,
        3);
  });

  test('bulk moves selected items and records bin time', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = ItemRepository(database.trackedItemsDao);
    final now = DateTime.now();
    for (var index = 0; index < 3; index++) {
      await repository.addItem(
        TrackedItemModel(
          id: 0,
          name: 'item-$index.txt',
          path: '/selection/item-$index.txt',
          type: ItemType.file,
          sizeBytes: index,
          category:
              index == 2 ? ItemCategory.temporary : ItemCategory.permanent,
          createdAt: now,
          lastUsedAt: now,
          isFlagged: false,
        ),
      );
    }

    final selected = await repository.getPermanentItemsPage(
      type: null,
      sort: ItemSort.name,
      search: '',
      limit: 10,
      offset: 0,
    );
    await repository.moveItemsToBin({
      for (final item in selected) item.id: '/system-trash/${item.name}',
    });

    final binned = await database.trackedItemsDao
        .getAllByCategory(ItemCategory.binned.name);
    final stillTemporary = await database.trackedItemsDao
        .getAllByCategory(ItemCategory.temporary.name);
    expect(binned, hasLength(2));
    expect(binned.every((item) => item.binnedAt != null), isTrue);
    expect(binned.every((item) => item.systemTrashPath != null), isTrue);
    expect(stillTemporary, hasLength(1));
    expect(stillTemporary.single.name, 'item-2.txt');

    await repository.categorizeMany(
      binned.map((item) => item.id).toList(),
      ItemCategory.temporary,
    );
    final restored = await database.trackedItemsDao
        .getAllByCategory(ItemCategory.temporary.name);
    expect(restored, hasLength(3));
    expect(restored.every((item) => item.systemTrashPath == null), isTrue);
  });
}
