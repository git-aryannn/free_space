// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TrackedItemsTable extends TrackedItems
    with TableInfo<$TrackedItemsTable, TrackedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  late final GeneratedColumnWithTypeConverter<ItemType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ItemType>($TrackedItemsTable.$convertertype);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<ItemCategory, String> category =
      GeneratedColumn<String>('category', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ItemCategory>($TrackedItemsTable.$convertercategory);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUsedAtMeta =
      const VerificationMeta('lastUsedAt');
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
      'last_used_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _temporarySinceMeta =
      const VerificationMeta('temporarySince');
  @override
  late final GeneratedColumn<DateTime> temporarySince =
      GeneratedColumn<DateTime>('temporary_since', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _binnedAtMeta =
      const VerificationMeta('binnedAt');
  @override
  late final GeneratedColumn<DateTime> binnedAt = GeneratedColumn<DateTime>(
      'binned_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _systemTrashPathMeta =
      const VerificationMeta('systemTrashPath');
  @override
  late final GeneratedColumn<String> systemTrashPath = GeneratedColumn<String>(
      'system_trash_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFlaggedMeta =
      const VerificationMeta('isFlagged');
  @override
  late final GeneratedColumn<bool> isFlagged = GeneratedColumn<bool>(
      'is_flagged', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_flagged" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        path,
        type,
        sizeBytes,
        mimeType,
        category,
        createdAt,
        lastUsedAt,
        temporarySince,
        binnedAt,
        systemTrashPath,
        isFlagged,
        thumbnailPath
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracked_items';
  @override
  VerificationContext validateIntegrity(Insertable<TrackedItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
          _lastUsedAtMeta,
          lastUsedAt.isAcceptableOrUnknown(
              data['last_used_at']!, _lastUsedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    if (data.containsKey('temporary_since')) {
      context.handle(
          _temporarySinceMeta,
          temporarySince.isAcceptableOrUnknown(
              data['temporary_since']!, _temporarySinceMeta));
    }
    if (data.containsKey('binned_at')) {
      context.handle(_binnedAtMeta,
          binnedAt.isAcceptableOrUnknown(data['binned_at']!, _binnedAtMeta));
    }
    if (data.containsKey('system_trash_path')) {
      context.handle(
          _systemTrashPathMeta,
          systemTrashPath.isAcceptableOrUnknown(
              data['system_trash_path']!, _systemTrashPathMeta));
    }
    if (data.containsKey('is_flagged')) {
      context.handle(_isFlaggedMeta,
          isFlagged.isAcceptableOrUnknown(data['is_flagged']!, _isFlaggedMeta));
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackedItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      type: $TrackedItemsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type']),
      category: $TrackedItemsTable.$convertercategory.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastUsedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used_at'])!,
      temporarySince: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}temporary_since']),
      binnedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}binned_at']),
      systemTrashPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}system_trash_path']),
      isFlagged: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_flagged'])!,
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path']),
    );
  }

  @override
  $TrackedItemsTable createAlias(String alias) {
    return $TrackedItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ItemType, String, String> $convertertype =
      const EnumNameConverter(ItemType.values);
  static JsonTypeConverter2<ItemCategory, String, String> $convertercategory =
      const EnumNameConverter(ItemCategory.values);
}

class TrackedItem extends DataClass implements Insertable<TrackedItem> {
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
  const TrackedItem(
      {required this.id,
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
      this.thumbnailPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['path'] = Variable<String>(path);
    {
      map['type'] =
          Variable<String>($TrackedItemsTable.$convertertype.toSql(type));
    }
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    {
      map['category'] = Variable<String>(
          $TrackedItemsTable.$convertercategory.toSql(category));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    if (!nullToAbsent || temporarySince != null) {
      map['temporary_since'] = Variable<DateTime>(temporarySince);
    }
    if (!nullToAbsent || binnedAt != null) {
      map['binned_at'] = Variable<DateTime>(binnedAt);
    }
    if (!nullToAbsent || systemTrashPath != null) {
      map['system_trash_path'] = Variable<String>(systemTrashPath);
    }
    map['is_flagged'] = Variable<bool>(isFlagged);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    return map;
  }

  TrackedItemsCompanion toCompanion(bool nullToAbsent) {
    return TrackedItemsCompanion(
      id: Value(id),
      name: Value(name),
      path: Value(path),
      type: Value(type),
      sizeBytes: Value(sizeBytes),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      category: Value(category),
      createdAt: Value(createdAt),
      lastUsedAt: Value(lastUsedAt),
      temporarySince: temporarySince == null && nullToAbsent
          ? const Value.absent()
          : Value(temporarySince),
      binnedAt: binnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(binnedAt),
      systemTrashPath: systemTrashPath == null && nullToAbsent
          ? const Value.absent()
          : Value(systemTrashPath),
      isFlagged: Value(isFlagged),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
    );
  }

  factory TrackedItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackedItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String>(json['path']),
      type: $TrackedItemsTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      category: $TrackedItemsTable.$convertercategory
          .fromJson(serializer.fromJson<String>(json['category'])),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
      temporarySince: serializer.fromJson<DateTime?>(json['temporarySince']),
      binnedAt: serializer.fromJson<DateTime?>(json['binnedAt']),
      systemTrashPath: serializer.fromJson<String?>(json['systemTrashPath']),
      isFlagged: serializer.fromJson<bool>(json['isFlagged']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String>(path),
      'type': serializer
          .toJson<String>($TrackedItemsTable.$convertertype.toJson(type)),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'mimeType': serializer.toJson<String?>(mimeType),
      'category': serializer.toJson<String>(
          $TrackedItemsTable.$convertercategory.toJson(category)),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
      'temporarySince': serializer.toJson<DateTime?>(temporarySince),
      'binnedAt': serializer.toJson<DateTime?>(binnedAt),
      'systemTrashPath': serializer.toJson<String?>(systemTrashPath),
      'isFlagged': serializer.toJson<bool>(isFlagged),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
    };
  }

  TrackedItem copyWith(
          {int? id,
          String? name,
          String? path,
          ItemType? type,
          int? sizeBytes,
          Value<String?> mimeType = const Value.absent(),
          ItemCategory? category,
          DateTime? createdAt,
          DateTime? lastUsedAt,
          Value<DateTime?> temporarySince = const Value.absent(),
          Value<DateTime?> binnedAt = const Value.absent(),
          Value<String?> systemTrashPath = const Value.absent(),
          bool? isFlagged,
          Value<String?> thumbnailPath = const Value.absent()}) =>
      TrackedItem(
        id: id ?? this.id,
        name: name ?? this.name,
        path: path ?? this.path,
        type: type ?? this.type,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        mimeType: mimeType.present ? mimeType.value : this.mimeType,
        category: category ?? this.category,
        createdAt: createdAt ?? this.createdAt,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
        temporarySince:
            temporarySince.present ? temporarySince.value : this.temporarySince,
        binnedAt: binnedAt.present ? binnedAt.value : this.binnedAt,
        systemTrashPath: systemTrashPath.present
            ? systemTrashPath.value
            : this.systemTrashPath,
        isFlagged: isFlagged ?? this.isFlagged,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
      );
  TrackedItem copyWithCompanion(TrackedItemsCompanion data) {
    return TrackedItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      type: data.type.present ? data.type.value : this.type,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      category: data.category.present ? data.category.value : this.category,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt:
          data.lastUsedAt.present ? data.lastUsedAt.value : this.lastUsedAt,
      temporarySince: data.temporarySince.present
          ? data.temporarySince.value
          : this.temporarySince,
      binnedAt: data.binnedAt.present ? data.binnedAt.value : this.binnedAt,
      systemTrashPath: data.systemTrashPath.present
          ? data.systemTrashPath.value
          : this.systemTrashPath,
      isFlagged: data.isFlagged.present ? data.isFlagged.value : this.isFlagged,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackedItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('type: $type, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('mimeType: $mimeType, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('temporarySince: $temporarySince, ')
          ..write('binnedAt: $binnedAt, ')
          ..write('systemTrashPath: $systemTrashPath, ')
          ..write('isFlagged: $isFlagged, ')
          ..write('thumbnailPath: $thumbnailPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      path,
      type,
      sizeBytes,
      mimeType,
      category,
      createdAt,
      lastUsedAt,
      temporarySince,
      binnedAt,
      systemTrashPath,
      isFlagged,
      thumbnailPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackedItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.path == this.path &&
          other.type == this.type &&
          other.sizeBytes == this.sizeBytes &&
          other.mimeType == this.mimeType &&
          other.category == this.category &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.temporarySince == this.temporarySince &&
          other.binnedAt == this.binnedAt &&
          other.systemTrashPath == this.systemTrashPath &&
          other.isFlagged == this.isFlagged &&
          other.thumbnailPath == this.thumbnailPath);
}

class TrackedItemsCompanion extends UpdateCompanion<TrackedItem> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> path;
  final Value<ItemType> type;
  final Value<int> sizeBytes;
  final Value<String?> mimeType;
  final Value<ItemCategory> category;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastUsedAt;
  final Value<DateTime?> temporarySince;
  final Value<DateTime?> binnedAt;
  final Value<String?> systemTrashPath;
  final Value<bool> isFlagged;
  final Value<String?> thumbnailPath;
  const TrackedItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.type = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.temporarySince = const Value.absent(),
    this.binnedAt = const Value.absent(),
    this.systemTrashPath = const Value.absent(),
    this.isFlagged = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
  });
  TrackedItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String path,
    required ItemType type,
    this.sizeBytes = const Value.absent(),
    this.mimeType = const Value.absent(),
    required ItemCategory category,
    required DateTime createdAt,
    required DateTime lastUsedAt,
    this.temporarySince = const Value.absent(),
    this.binnedAt = const Value.absent(),
    this.systemTrashPath = const Value.absent(),
    this.isFlagged = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
  })  : name = Value(name),
        path = Value(path),
        type = Value(type),
        category = Value(category),
        createdAt = Value(createdAt),
        lastUsedAt = Value(lastUsedAt);
  static Insertable<TrackedItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? path,
    Expression<String>? type,
    Expression<int>? sizeBytes,
    Expression<String>? mimeType,
    Expression<String>? category,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
    Expression<DateTime>? temporarySince,
    Expression<DateTime>? binnedAt,
    Expression<String>? systemTrashPath,
    Expression<bool>? isFlagged,
    Expression<String>? thumbnailPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (type != null) 'type': type,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (mimeType != null) 'mime_type': mimeType,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (temporarySince != null) 'temporary_since': temporarySince,
      if (binnedAt != null) 'binned_at': binnedAt,
      if (systemTrashPath != null) 'system_trash_path': systemTrashPath,
      if (isFlagged != null) 'is_flagged': isFlagged,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
    });
  }

  TrackedItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? path,
      Value<ItemType>? type,
      Value<int>? sizeBytes,
      Value<String?>? mimeType,
      Value<ItemCategory>? category,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastUsedAt,
      Value<DateTime?>? temporarySince,
      Value<DateTime?>? binnedAt,
      Value<String?>? systemTrashPath,
      Value<bool>? isFlagged,
      Value<String?>? thumbnailPath}) {
    return TrackedItemsCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($TrackedItemsTable.$convertertype.toSql(type.value));
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
          $TrackedItemsTable.$convertercategory.toSql(category.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (temporarySince.present) {
      map['temporary_since'] = Variable<DateTime>(temporarySince.value);
    }
    if (binnedAt.present) {
      map['binned_at'] = Variable<DateTime>(binnedAt.value);
    }
    if (systemTrashPath.present) {
      map['system_trash_path'] = Variable<String>(systemTrashPath.value);
    }
    if (isFlagged.present) {
      map['is_flagged'] = Variable<bool>(isFlagged.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackedItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('type: $type, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('mimeType: $mimeType, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('temporarySince: $temporarySince, ')
          ..write('binnedAt: $binnedAt, ')
          ..write('systemTrashPath: $systemTrashPath, ')
          ..write('isFlagged: $isFlagged, ')
          ..write('thumbnailPath: $thumbnailPath')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<AppSettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final String key;
  final String value;
  const AppSettingsTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingsTableData copyWith({String? key, String? value}) =>
      AppSettingsTableData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrackedItemsTable trackedItems = $TrackedItemsTable(this);
  late final $AppSettingsTableTable appSettingsTable =
      $AppSettingsTableTable(this);
  late final TrackedItemsDao trackedItemsDao =
      TrackedItemsDao(this as AppDatabase);
  late final AppSettingsDao appSettingsDao =
      AppSettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [trackedItems, appSettingsTable];
}

typedef $$TrackedItemsTableCreateCompanionBuilder = TrackedItemsCompanion
    Function({
  Value<int> id,
  required String name,
  required String path,
  required ItemType type,
  Value<int> sizeBytes,
  Value<String?> mimeType,
  required ItemCategory category,
  required DateTime createdAt,
  required DateTime lastUsedAt,
  Value<DateTime?> temporarySince,
  Value<DateTime?> binnedAt,
  Value<String?> systemTrashPath,
  Value<bool> isFlagged,
  Value<String?> thumbnailPath,
});
typedef $$TrackedItemsTableUpdateCompanionBuilder = TrackedItemsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> path,
  Value<ItemType> type,
  Value<int> sizeBytes,
  Value<String?> mimeType,
  Value<ItemCategory> category,
  Value<DateTime> createdAt,
  Value<DateTime> lastUsedAt,
  Value<DateTime?> temporarySince,
  Value<DateTime?> binnedAt,
  Value<String?> systemTrashPath,
  Value<bool> isFlagged,
  Value<String?> thumbnailPath,
});

class $$TrackedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackedItemsTable> {
  $$TrackedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ItemType, ItemType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ItemCategory, ItemCategory, String>
      get category => $composableBuilder(
          column: $table.category,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get temporarySince => $composableBuilder(
      column: $table.temporarySince,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get binnedAt => $composableBuilder(
      column: $table.binnedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get systemTrashPath => $composableBuilder(
      column: $table.systemTrashPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFlagged => $composableBuilder(
      column: $table.isFlagged, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));
}

class $$TrackedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackedItemsTable> {
  $$TrackedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get temporarySince => $composableBuilder(
      column: $table.temporarySince,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get binnedAt => $composableBuilder(
      column: $table.binnedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get systemTrashPath => $composableBuilder(
      column: $table.systemTrashPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFlagged => $composableBuilder(
      column: $table.isFlagged, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));
}

class $$TrackedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackedItemsTable> {
  $$TrackedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ItemType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ItemCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get temporarySince => $composableBuilder(
      column: $table.temporarySince, builder: (column) => column);

  GeneratedColumn<DateTime> get binnedAt =>
      $composableBuilder(column: $table.binnedAt, builder: (column) => column);

  GeneratedColumn<String> get systemTrashPath => $composableBuilder(
      column: $table.systemTrashPath, builder: (column) => column);

  GeneratedColumn<bool> get isFlagged =>
      $composableBuilder(column: $table.isFlagged, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);
}

class $$TrackedItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrackedItemsTable,
    TrackedItem,
    $$TrackedItemsTableFilterComposer,
    $$TrackedItemsTableOrderingComposer,
    $$TrackedItemsTableAnnotationComposer,
    $$TrackedItemsTableCreateCompanionBuilder,
    $$TrackedItemsTableUpdateCompanionBuilder,
    (
      TrackedItem,
      BaseReferences<_$AppDatabase, $TrackedItemsTable, TrackedItem>
    ),
    TrackedItem,
    PrefetchHooks Function()> {
  $$TrackedItemsTableTableManager(_$AppDatabase db, $TrackedItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<ItemType> type = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<ItemCategory> category = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastUsedAt = const Value.absent(),
            Value<DateTime?> temporarySince = const Value.absent(),
            Value<DateTime?> binnedAt = const Value.absent(),
            Value<String?> systemTrashPath = const Value.absent(),
            Value<bool> isFlagged = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
          }) =>
              TrackedItemsCompanion(
            id: id,
            name: name,
            path: path,
            type: type,
            sizeBytes: sizeBytes,
            mimeType: mimeType,
            category: category,
            createdAt: createdAt,
            lastUsedAt: lastUsedAt,
            temporarySince: temporarySince,
            binnedAt: binnedAt,
            systemTrashPath: systemTrashPath,
            isFlagged: isFlagged,
            thumbnailPath: thumbnailPath,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String path,
            required ItemType type,
            Value<int> sizeBytes = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            required ItemCategory category,
            required DateTime createdAt,
            required DateTime lastUsedAt,
            Value<DateTime?> temporarySince = const Value.absent(),
            Value<DateTime?> binnedAt = const Value.absent(),
            Value<String?> systemTrashPath = const Value.absent(),
            Value<bool> isFlagged = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
          }) =>
              TrackedItemsCompanion.insert(
            id: id,
            name: name,
            path: path,
            type: type,
            sizeBytes: sizeBytes,
            mimeType: mimeType,
            category: category,
            createdAt: createdAt,
            lastUsedAt: lastUsedAt,
            temporarySince: temporarySince,
            binnedAt: binnedAt,
            systemTrashPath: systemTrashPath,
            isFlagged: isFlagged,
            thumbnailPath: thumbnailPath,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TrackedItemsTable, TrackedItem>(table),
                    BaseReferences<_$AppDatabase, $TrackedItemsTable,
                        TrackedItem>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrackedItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrackedItemsTable,
    TrackedItem,
    $$TrackedItemsTableFilterComposer,
    $$TrackedItemsTableOrderingComposer,
    $$TrackedItemsTableAnnotationComposer,
    $$TrackedItemsTableCreateCompanionBuilder,
    $$TrackedItemsTableUpdateCompanionBuilder,
    (
      TrackedItem,
      BaseReferences<_$AppDatabase, $TrackedItemsTable, TrackedItem>
    ),
    TrackedItem,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableTableCreateCompanionBuilder
    = AppSettingsTableCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableTableUpdateCompanionBuilder
    = AppSettingsTableCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTableTable,
    AppSettingsTableData,
    $$AppSettingsTableTableFilterComposer,
    $$AppSettingsTableTableOrderingComposer,
    $$AppSettingsTableTableAnnotationComposer,
    $$AppSettingsTableTableCreateCompanionBuilder,
    $$AppSettingsTableTableUpdateCompanionBuilder,
    (
      AppSettingsTableData,
      BaseReferences<_$AppDatabase, $AppSettingsTableTable,
          AppSettingsTableData>
    ),
    AppSettingsTableData,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableTableManager(
      _$AppDatabase db, $AppSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsTableCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsTableCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppSettingsTableTable, AppSettingsTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $AppSettingsTableTable,
                        AppSettingsTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTableTable,
    AppSettingsTableData,
    $$AppSettingsTableTableFilterComposer,
    $$AppSettingsTableTableOrderingComposer,
    $$AppSettingsTableTableAnnotationComposer,
    $$AppSettingsTableTableCreateCompanionBuilder,
    $$AppSettingsTableTableUpdateCompanionBuilder,
    (
      AppSettingsTableData,
      BaseReferences<_$AppDatabase, $AppSettingsTableTable,
          AppSettingsTableData>
    ),
    AppSettingsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrackedItemsTableTableManager get trackedItems =>
      $$TrackedItemsTableTableManager(_db, _db.trackedItems);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}

mixin _$TrackedItemsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrackedItemsTable get trackedItems => attachedDatabase.trackedItems;
  TrackedItemsDaoManager get managers => TrackedItemsDaoManager(this);
}

class TrackedItemsDaoManager {
  final _$TrackedItemsDaoMixin _db;
  TrackedItemsDaoManager(this._db);
  $$TrackedItemsTableTableManager get trackedItems =>
      $$TrackedItemsTableTableManager(_db.attachedDatabase, _db.trackedItems);
}

mixin _$AppSettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSettingsTableTable get appSettingsTable =>
      attachedDatabase.appSettingsTable;
  AppSettingsDaoManager get managers => AppSettingsDaoManager(this);
}

class AppSettingsDaoManager {
  final _$AppSettingsDaoMixin _db;
  AppSettingsDaoManager(this._db);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(
          _db.attachedDatabase, _db.appSettingsTable);
}
