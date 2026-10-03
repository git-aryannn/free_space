import 'package:drift/drift.dart';
import 'package:free_space/data/database/app_database.dart';
import 'package:free_space/data/models/item_enums.dart';

/// A domain model representing a tracked item.
class TrackedItemModel {
  final int id;
  final String name;
  final String path;
  final ItemType type;
  final int sizeBytes;
  final String? mimeType;
  final ItemCategory category;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final DateTime? temporarySince;
  final DateTime? binnedAt;
  final String? systemTrashPath;
  final bool isFlagged;
  final String? thumbnailPath;

  const TrackedItemModel({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.sizeBytes,
    this.mimeType,
    required this.category,
    required this.createdAt,
    required this.lastUsedAt,
    this.temporarySince,
    this.binnedAt,
    this.systemTrashPath,
    required this.isFlagged,
    this.thumbnailPath,
  });

  /// Creates a model from a database row.
  factory TrackedItemModel.fromDbRow(TrackedItem row) {
    return TrackedItemModel(
      id: row.id,
      name: row.name,
      path: row.path,
      type: row.type,
      sizeBytes: row.sizeBytes,
      mimeType: row.mimeType,
      category: row.category,
      createdAt: row.createdAt,
      lastUsedAt: row.lastUsedAt,
      temporarySince: row.temporarySince,
      binnedAt: row.binnedAt,
      systemTrashPath: row.systemTrashPath,
      isFlagged: row.isFlagged,
      thumbnailPath: row.thumbnailPath,
    );
  }

  /// Converts this model to a Drift companion for insertion/updates.
  TrackedItemsCompanion toCompanion() {
    return TrackedItemsCompanion(
      id: id > 0 ? Value(id) : const Value.absent(),
      name: Value(name),
      path: Value(path),
      type: Value(type),
      sizeBytes: Value(sizeBytes),
      mimeType: mimeType == null ? const Value.absent() : Value(mimeType),
      category: Value(category),
      createdAt: Value(createdAt),
      lastUsedAt: Value(lastUsedAt),
      temporarySince: Value(temporarySince),
      binnedAt: Value(binnedAt),
      systemTrashPath: Value(systemTrashPath),
      isFlagged: Value(isFlagged),
      thumbnailPath:
          thumbnailPath == null ? const Value.absent() : Value(thumbnailPath),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type.name,
      'sizeBytes': sizeBytes,
      'mimeType': mimeType,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt.toIso8601String(),
      'temporarySince': temporarySince?.toIso8601String(),
      'binnedAt': binnedAt?.toIso8601String(),
      'systemTrashPath': systemTrashPath,
      'isFlagged': isFlagged,
      'thumbnailPath': thumbnailPath,
    };
  }

  factory TrackedItemModel.fromJson(Map<String, dynamic> json) {
    return TrackedItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      path: json['path'] as String,
      type: ItemType.values.firstWhere((e) => e.name == json['type']),
      sizeBytes: json['sizeBytes'] as int,
      mimeType: json['mimeType'] as String?,
      category:
          ItemCategory.values.firstWhere((e) => e.name == json['category']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
      temporarySince: json['temporarySince'] != null
          ? DateTime.parse(json['temporarySince'] as String)
          : null,
      binnedAt: json['binnedAt'] != null
          ? DateTime.parse(json['binnedAt'] as String)
          : null,
      systemTrashPath: json['systemTrashPath'] as String?,
      isFlagged: json['isFlagged'] as bool,
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }

  /// Creates a copy of this model with the given fields replaced with the new values.
  TrackedItemModel copyWith({
    int? id,
    String? name,
    String? path,
    ItemType? type,
    int? sizeBytes,
    String? mimeType,
    ItemCategory? category,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    DateTime? temporarySince,
    DateTime? binnedAt,
    String? systemTrashPath,
    bool? isFlagged,
    String? thumbnailPath,
  }) {
    return TrackedItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      mimeType: mimeType ?? this.mimeType,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      temporarySince: temporarySince ?? this.temporarySince,
      binnedAt: binnedAt ?? this.binnedAt,
      systemTrashPath: systemTrashPath ?? this.systemTrashPath,
      isFlagged: isFlagged ?? this.isFlagged,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  /// Returns the number of days since the item was last used.
  int get daysUnused {
    final now = DateTime.now();
    final lastUsed = lastUsedAt.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final lastUsedDay = DateTime(lastUsed.year, lastUsed.month, lastUsed.day);
    final days = today.difference(lastUsedDay).inDays;
    return days < 0 ? 0 : days;
  }

  /// Checks if the item is ready to be binned based on an inactivity threshold.
  bool isReadyToBin(int thresholdDays) {
    return daysUnused >= thresholdDays;
  }

  int daysUntilBinned(int thresholdDays) {
    if (thresholdDays <= 0) return 0;
    final startDate = (temporarySince ?? lastUsedAt).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(startDate.year, startDate.month, startDate.day);
    final daysInTemporary = today.difference(startDay).inDays.clamp(0, 1 << 31);
    return (thresholdDays - daysInTemporary).clamp(0, thresholdDays);
  }

  int daysUntilPermanentDeletion(int retentionDays) {
    final trashedAt = binnedAt;
    if (trashedAt == null) return retentionDays;
    final remaining =
        trashedAt.add(Duration(days: retentionDays)).difference(DateTime.now());
    if (remaining.isNegative || remaining == Duration.zero) return 0;
    return (remaining.inSeconds / Duration.secondsPerDay).ceil();
  }

  /// Returns a human-readable string representation of the file size.
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    }
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
