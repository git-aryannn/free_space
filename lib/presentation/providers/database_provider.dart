import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/data/database/app_database.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Provides the singleton instance of AppDatabase
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase(_openConnection());
});

/// Provides the TrackedItemsDao instance
final trackedItemsDaoProvider = Provider<TrackedItemsDao>((ref) {
  return ref.watch(databaseProvider).trackedItemsDao;
});

/// Provides the AppSettingsDao instance
final appSettingsDaoProvider = Provider<AppSettingsDao>((ref) {
  return ref.watch(databaseProvider).appSettingsDao;
});

/// Provides the total space saved in bytes.
final totalSpaceSavedProvider = StreamProvider<int>((ref) {
  return ref.watch(appSettingsDaoProvider).watchSetting('total_space_saved').map((val) {
    return int.tryParse(val ?? '0') ?? 0;
  });
});
