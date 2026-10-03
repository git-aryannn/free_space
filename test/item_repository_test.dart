import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_space/data/database/app_database.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/repositories/item_repository.dart';
import 'package:free_space/data/services/system_file_scan_service.dart';

void main() {
  test('registers Finder-restored paths in the requested category', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final directory = await Directory.systemTemp.createTemp(
      'free-space-restored-item-',
    );
    addTearDown(() async {
      await database.close();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final file = File('${directory.path}/restored-song.mp3');
    await file.writeAsBytes([1, 2, 3]);
    final repository = ItemRepository(
      TrackedItemsDao(database),
      systemFileScanService: SystemFileScanService(),
    );

    final count = await repository.registerRestoredPaths(
      [file.path],
      ItemCategory.temporary,
    );
    final temporaryItems = await repository.watchTemporaryItems().first;

    expect(count, 1);
    expect(temporaryItems, hasLength(1));
    expect(temporaryItems.single.path, file.path);
    expect(temporaryItems.single.category, ItemCategory.temporary);
  });
}
