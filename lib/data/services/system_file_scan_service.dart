import 'dart:developer' as developer;
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/data/services/native_platform_service.dart';

class SystemScanResult {
  final int discoveredItems;
  final int inaccessibleDirectories;

  const SystemScanResult({
    required this.discoveredItems,
    required this.inaccessibleDirectories,
  });
}

class SystemFileScanService {
  static const int _batchSize = 500;
  final NativePlatformService? _nativePlatformService;

  SystemFileScanService({NativePlatformService? nativePlatformService})
      : _nativePlatformService = nativePlatformService;

  static const Set<String> _mediaExtensions = {
    '.aac',
    '.aiff',
    '.avi',
    '.bmp',
    '.flac',
    '.gif',
    '.heic',
    '.jpeg',
    '.jpg',
    '.m4a',
    '.m4v',
    '.mkv',
    '.mov',
    '.mp3',
    '.mp4',
    '.mpeg',
    '.mpg',
    '.png',
    '.tif',
    '.tiff',
    '.wav',
    '.webm',
    '.webp',
  };

  Future<SystemScanResult> scan(
    String rootPath, {
    required Future<void> Function(List<TrackedItemModel>) saveBatch,
    void Function(int discoveredItems)? onProgress,
    List<String> ignoredPaths = const [],
  }) =>
      scanPaths(
        [rootPath],
        saveBatch: saveBatch,
        onProgress: onProgress,
        ignoredPaths: ignoredPaths,
      );

  Future<SystemScanResult> scanPaths(
    List<String> paths, {
    required Future<void> Function(List<TrackedItemModel>) saveBatch,
    void Function(int discoveredItems)? onProgress,
    List<String> ignoredPaths = const [],
  }) async {
    final batch = <TrackedItemModel>[];
    final pendingDirectories = <Directory>[];
    final visitedPaths = <String>{};
    var discoveredItems = 0;
    var inaccessibleDirectories = 0;

    Future<void> addItem(TrackedItemModel item) async {
      batch.add(item);
      discoveredItems++;
      if (batch.length >= _batchSize) {
        await saveBatch(List<TrackedItemModel>.of(batch));
        batch.clear();
        onProgress?.call(discoveredItems);
      }
    }

    Future<void> processEntity(FileSystemEntity entity) async {
      if (!visitedPaths.add(entity.absolute.path)) return;
      try {
        if (await FileSystemEntity.type(
              entity.path,
              followLinks: true,
            ) ==
            FileSystemEntityType.link) {
          return;
        }
        final stat = await entity.stat();
        if (stat.type == FileSystemEntityType.directory) {
          if (p.extension(entity.path).toLowerCase() == '.app') {
            await addItem(
              _makeItem(
                path: entity.path,
                type: ItemType.app,
                sizeBytes: stat.size,
                modifiedAt: stat.modified,
                accessedAt: stat.modified,
              ),
            );
          } else {
            pendingDirectories.add(Directory(entity.path));
          }
        } else if (stat.type == FileSystemEntityType.file) {
          final extension = p.extension(entity.path).toLowerCase();
          await addItem(
            _makeItem(
              path: entity.path,
              type: _mediaExtensions.contains(extension)
                  ? ItemType.media
                  : ItemType.file,
              sizeBytes: stat.size,
              modifiedAt: stat.modified,
              accessedAt: stat.modified,
            ),
          );
        }
      } on FileSystemException catch (error) {
        developer.log(
          'Skipping inaccessible filesystem entry: ${entity.path}',
          error: error,
        );
      }
    }

    if (paths.isEmpty) {
      throw ArgumentError.value(paths, 'paths', 'Select at least one item.');
    }
    if (paths.length == 1 && Uri.tryParse(paths.first)?.scheme == 'content') {
      return _scanDocumentTree(
        paths.single,
        saveBatch: saveBatch,
        onProgress: onProgress,
        ignoredPaths: ignoredPaths,
      );
    }
    for (var path in paths) {
      try {
        path = File(path).resolveSymbolicLinksSync();
      } catch (_) {}

      final entityType = await FileSystemEntity.type(path, followLinks: true);
      if (entityType == FileSystemEntityType.notFound) {
        throw FileSystemException('Selected item does not exist', path);
      }
      if (entityType == FileSystemEntityType.directory ||
          entityType == FileSystemEntityType.file) {
        await processEntity(
          entityType == FileSystemEntityType.directory
              ? Directory(path)
              : File(path),
        );
      }
    }

    while (pendingDirectories.isNotEmpty) {
      final directory = pendingDirectories.removeLast();
      try {
        await for (final entity
            in directory.list(followLinks: true, recursive: false)) {
          await processEntity(entity);
        }
      } on FileSystemException catch (error) {
        inaccessibleDirectories++;
        developer.log(
          'Skipping inaccessible directory: ${directory.path}',
          error: error,
        );
      }
    }

    if (batch.isNotEmpty) {
      await saveBatch(batch);
      onProgress?.call(discoveredItems);
    }

    return SystemScanResult(
      discoveredItems: discoveredItems,
      inaccessibleDirectories: inaccessibleDirectories,
    );
  }

  Future<SystemScanResult> _scanDocumentTree(
    String treeUri, {
    required Future<void> Function(List<TrackedItemModel>) saveBatch,
    void Function(int discoveredItems)? onProgress,
    List<String> ignoredPaths = const [],
  }) async {
    final nativeService = _nativePlatformService;
    if (nativeService == null) {
      throw StateError('Folder scanning is not available on this platform.');
    }
    final result = await nativeService.scanDocumentTree(treeUri);
    final entries = result['items'] as List<Map<String, dynamic>>;
    final batch = <TrackedItemModel>[];
    var discoveredItems = 0;

    for (final entry in entries) {
      final name = entry['name'];
      final path = entry['path'];
      if (name is! String || path is! String) continue;
      final sizeBytes = (entry['sizeBytes'] as num?)?.toInt() ?? 0;
      final modifiedMillis = (entry['lastModified'] as num?)?.toInt() ?? 0;
      final modifiedAt = modifiedMillis > 0
          ? DateTime.fromMillisecondsSinceEpoch(modifiedMillis)
          : DateTime.now();
      batch.add(
        _makeItem(
          path: path,
          type: _mediaExtensions.contains(p.extension(name).toLowerCase())
              ? ItemType.media
              : ItemType.file,
          sizeBytes: sizeBytes,
          modifiedAt: modifiedAt,
          accessedAt: modifiedAt,
        ),
      );
      discoveredItems++;
      if (batch.length >= _batchSize) {
        await saveBatch(List<TrackedItemModel>.of(batch));
        batch.clear();
        onProgress?.call(discoveredItems);
      }
    }
    if (batch.isNotEmpty) {
      await saveBatch(batch);
      onProgress?.call(discoveredItems);
    }
    return SystemScanResult(
      discoveredItems: discoveredItems,
      inaccessibleDirectories:
          (result['inaccessibleDirectories'] as num?)?.toInt() ?? 0,
    );
  }

  TrackedItemModel _makeItem({
    required String path,
    required ItemType type,
    required int sizeBytes,
    required DateTime modifiedAt,
    required DateTime accessedAt,
  }) {
    return TrackedItemModel(
      id: 0,
      name: p.basename(path),
      path: path,
      type: type,
      sizeBytes: sizeBytes,
      category: ItemCategory.permanent,
      createdAt: modifiedAt,
      lastUsedAt: accessedAt,
      isFlagged: false,
    );
  }

  DateTime _usableAccessDate(DateTime accessedAt, DateTime modifiedAt) {
    return accessedAt.year < 2000 ? modifiedAt : accessedAt;
  }
}
