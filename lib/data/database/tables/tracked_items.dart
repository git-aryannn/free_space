import 'package:drift/drift.dart';
import 'package:free_space/data/models/item_enums.dart';

/// Defines the tracked_items table for the database
class TrackedItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get path => text().unique()();
  TextColumn get type => text().map(const EnumNameConverter(ItemType.values))();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get mimeType => text().nullable()();
  TextColumn get category =>
      text().map(const EnumNameConverter(ItemCategory.values))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime()();
  DateTimeColumn get temporarySince => dateTime().nullable()();
  DateTimeColumn get binnedAt => dateTime().nullable()();
  TextColumn get systemTrashPath => text().nullable()();
  BoolColumn get isFlagged => boolean().withDefault(const Constant(false))();
  TextColumn get thumbnailPath => text().nullable()();
}
