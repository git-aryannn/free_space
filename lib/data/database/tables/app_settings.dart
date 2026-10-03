import 'package:drift/drift.dart';

/// Defines the app_settings table for the database
class AppSettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
