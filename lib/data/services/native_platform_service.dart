import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class SystemTrashItem {
  final String name;
  final String trashPath;
  final int sizeBytes;

  const SystemTrashItem({
    required this.name,
    required this.trashPath,
    required this.sizeBytes,
  });

  factory SystemTrashItem.fromMap(Map<Object?, Object?> map) {
    final name = map['name'];
    final path = map['trashPath'];
    final size = map['sizeBytes'];
    if (name is! String || path is! String || size is! int) {
      throw const FormatException('Invalid item returned from system Trash.');
    }
    return SystemTrashItem(name: name, trashPath: path, sizeBytes: size);
  }
}

/// A service to interact with native platform APIs via MethodChannel.
class NativePlatformService {
  static const MethodChannel _channel =
      MethodChannel('com.freespace.app/platform');
  Function(Map<String, dynamic>)? _onNewFileDetectedCallback;

  /// Initializes the service and sets up the method call handler for native to Flutter communication.
  NativePlatformService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNewFileDetected':
        if (_onNewFileDetectedCallback != null && call.arguments != null) {
          try {
            final args = Map<String, dynamic>.from(call.arguments);
            _onNewFileDetectedCallback!(args);
          } catch (e) {
            developer.log('Error parsing onNewFileDetected arguments',
                error: e);
          }
        }
        break;
      default:
        developer.log('Unhandled method call: ${call.method}');
    }
  }

  /// Sets a callback to be invoked when a new file is detected natively.
  void setOnNewFileDetected(Function(Map<String, dynamic>) callback) {
    _onNewFileDetectedCallback = callback;
  }

  /// Retrieves storage information (total, used, free bytes).
  Future<Map<String, int>> getStorageInfo() async {
    try {
      final result =
          await _channel.invokeMethod<Map<Object?, Object?>>('getStorageInfo');
      if (result != null) {
        return result
            .map((key, value) => MapEntry(key.toString(), value as int));
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get storage info', error: e);
      rethrow;
    }
    return {'totalBytes': 0, 'usedBytes': 0, 'freeBytes': 0};
  }

  Future<Map<String, dynamic>> scanDocumentTree(String treeUri) async {
    final result = await _channel.invokeMethod<Map<Object?, Object?>>(
      'scanDocumentTree',
      {'treeUri': treeUri},
    );
    if (result == null || result['items'] is! List) {
      throw const FormatException('Invalid result returned from folder scan.');
    }
    final items = (result['items'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    return {
      'items': items,
      'inaccessibleDirectories':
          (result['inaccessibleDirectories'] as num?)?.toInt() ?? 0,
    };
  }

  /// Scans a directory at the given path.
  Future<List<Map<String, dynamic>>> scanDirectory(String path) async {
    try {
      final result = await _channel
          .invokeMethod<List<Object?>>('scanDirectory', {'path': path});
      if (result != null) {
        return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to scan directory: $path', error: e);
    }
    return [];
  }

  /// Retrieves app usage stats for Android. Returns empty list on unsupported platforms.
  Future<List<Map<String, dynamic>>> getAppUsageStats(
      int startTime, int endTime) async {
    try {
      final result =
          await _channel.invokeMethod<List<Object?>>('getAppUsageStats', {
        'startTime': startTime,
        'endTime': endTime,
      });
      if (result != null) {
        return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get app usage stats', error: e);
    }
    return [];
  }

  /// Retrieves a list of installed apps for Android. Returns empty list on unsupported platforms.
  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result =
          await _channel.invokeMethod<List<Object?>>('getInstalledApps');
      if (result != null) {
        return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get installed apps', error: e);
    }
    return [];
  }

  /// Requests a specific permission type from the native platform.
  Future<bool> requestPermission(String type) async {
    try {
      final result = await _channel
          .invokeMethod<bool>('requestPermission', {'type': type});
      return result ?? false;
    } on PlatformException catch (e) {
      developer.log('Failed to request permission: $type', error: e);
      return false;
    }
  }

  Future<bool> requestAllFilesAccess() async {
    try {
      return await _channel.invokeMethod<bool>('requestAllFilesAccess') ??
          false;
    } on PlatformException catch (e) {
      developer.log('Failed to request all-files access', error: e);
      rethrow;
    }
  }

  Future<bool> hasNotificationPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasNotificationPermission') ??
          false;
    } on PlatformException catch (e) {
      developer.log('Failed to check notification access', error: e);
      rethrow;
    }
  }

  Future<bool> requestNotificationPermission() async {
    try {
      return await _channel.invokeMethod<bool>(
            'requestNotificationPermission',
          ) ??
          false;
    } on PlatformException catch (e) {
      developer.log('Failed to request notification access', error: e);
      rethrow;
    }
  }

  Future<bool> hasAllFilesAccess() async {
    try {
      return await _channel.invokeMethod<bool>('hasAllFilesAccess') ?? false;
    } on PlatformException catch (e) {
      developer.log('Failed to check all-files access', error: e);
      rethrow;
    }
  }

  Future<String> getDownloadsPath() async {
    final path = await _channel.invokeMethod<String>('getDownloadsPath');
    if (path == null || path.isEmpty) {
      throw const FormatException('Android did not return the Downloads path.');
    }
    return path;
  }

  Future<String> getExternalStorageRootPath() async {
    final path =
        await _channel.invokeMethod<String>('getExternalStorageRootPath');
    if (path == null || path.isEmpty) {
      throw const FormatException(
          'Android did not return the storage root path.');
    }
    return path;
  }

  Future<void> setScanRoot(String path) async {
    await _channel.invokeMethod('setScanRoot', {'path': path});
  }

  /// Opens the native folder picker and persists permission to the chosen root.
  Future<String?> selectScanRoot() async {
    try {
      return await _channel.invokeMethod<String>('selectScanRoot');
    } on PlatformException catch (e) {
      developer.log('Failed to select a scan folder', error: e);
      rethrow;
    }
  }

  /// Opens a picker to select specific files and folders to scan.
  Future<List<String>?> selectScanItems() async {
    try {
      final paths = await _channel.invokeMethod<List<Object?>>(
        'selectScanItems',
      );
      return paths?.cast<String>();
    } on PlatformException catch (e) {
      developer.log('Failed to select files and folders to scan', error: e);
      rethrow;
    }
  }

  /// Resolves the previously authorized scan root, if one was selected.
  Future<String?> getScanRoot() async {
    try {
      return await _channel.invokeMethod<String>('getScanRoot');
    } on PlatformException catch (e) {
      developer.log('Failed to load the authorized scan folder', error: e);
      rethrow;
    }
  }

  Future<String?> getScanRootDisplayPath() async {
    try {
      return await _channel.invokeMethod<String>('getScanRootPath');
    } on PlatformException catch (e) {
      developer.log('Failed to load the selected folder path', error: e);
      rethrow;
    }
  }

  Future<bool> showInFileManager(String path) async {
    try {
      return await _channel.invokeMethod<bool>(
            'showInFileManager',
            {'path': path},
          ) ??
          false;
    } on PlatformException catch (e) {
      developer.log('Failed to show item in file manager: $path', error: e);
      rethrow;
    }
  }

  Future<Map<String, String?>> moveItemsToSystemTrash(
    List<String> paths,
  ) async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'moveItemsToSystemTrash',
        {'paths': paths},
      );
      if (result == null) {
        throw PlatformException(
          code: 'TRASH_FAILED',
          message: 'The system did not confirm moving items to Trash.',
        );
      }
      return result.map(
        (path, trashPath) => MapEntry(path.toString(), trashPath?.toString()),
      );
    } on PlatformException catch (e) {
      developer.log('Failed to move items to the system trash', error: e);
      rethrow;
    }
  }

  Future<void> restoreItemsFromSystemTrash(
    List<({String originalPath, String? trashPath})> items,
  ) async {
    try {
      final restored = await _channel.invokeMethod<bool>(
        'restoreItemsFromSystemTrash',
        {
          'items': items
              .map((item) => {
                    'originalPath': item.originalPath,
                    'trashPath': item.trashPath,
                  })
              .toList(),
        },
      );
      if (restored != true) {
        throw PlatformException(
          code: 'RESTORE_FAILED',
          message: 'The system did not confirm restoring items from Trash.',
        );
      }
    } on PlatformException catch (e) {
      developer.log('Failed to restore items from the system trash', error: e);
      rethrow;
    }
  }

  Future<Map<String, String>> putBackSystemTrashItems(
    List<String> trashPaths,
  ) async {
    try {
      final restored = await _channel.invokeMethod<Map<Object?, Object?>>(
        'putBackSystemTrashItems',
        {'paths': trashPaths},
      );
      if (restored == null) {
        throw PlatformException(
          code: 'RESTORE_FAILED',
          message: 'Finder did not confirm putting the items back.',
        );
      }
      return restored.map(
        (trashPath, originalPath) => MapEntry(
          trashPath.toString(),
          originalPath.toString(),
        ),
      );
    } on PlatformException catch (e) {
      developer.log('Failed to put back items from system Trash', error: e);
      rethrow;
    }
  }

  Future<Set<String>> permanentlyDeleteItemsFromSystemTrash(
    List<String> trashPaths,
  ) async {
    try {
      final deleted = await _channel.invokeMethod<List<Object?>>(
        'permanentlyDeleteItemsFromSystemTrash',
        {'paths': trashPaths},
      );
      if (deleted == null) {
        throw PlatformException(
          code: 'PERMANENT_DELETE_FAILED',
          message: 'The system did not confirm permanent deletion.',
        );
      }
      return deleted.cast<String>().toSet();
    } on PlatformException catch (e) {
      developer.log('Failed to permanently delete items from system Trash',
          error: e);
      rethrow;
    }
  }

  Future<List<SystemTrashItem>> listSystemTrashItems({
    bool requestAccess = false,
  }) async {
    try {
      final items = await _channel.invokeMethod<List<Object?>>(
        'listSystemTrashItems',
        {'requestAccess': requestAccess},
      );
      if (items == null) {
        throw PlatformException(
          code: 'SYSTEM_TRASH_READ_FAILED',
          message: 'The system did not return its Trash contents.',
        );
      }
      return items
          .map((item) =>
              SystemTrashItem.fromMap(Map<Object?, Object?>.from(item as Map)))
          .toList();
    } on PlatformException catch (e) {
      developer.log('Failed to list system Trash items', error: e);
      rethrow;
    } on FormatException catch (e) {
      developer.log('Invalid item data returned from system Trash', error: e);
      rethrow;
    }
  }

  /// Starts a file observer on the native side for the given paths.
  Future<void> startFileObserver(List<String> paths) async {
    try {
      await _channel.invokeMethod('startFileObserver', {'paths': paths});
    } on PlatformException catch (e) {
      developer.log('Failed to start file observer for paths: $paths',
          error: e);
    }
  }
}
