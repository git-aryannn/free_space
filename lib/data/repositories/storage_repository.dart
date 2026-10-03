import 'package:free_space/data/services/native_platform_service.dart';

/// Represents storage information from the native platform.
class StorageInfo {
  final int totalBytes;
  final int usedBytes;
  final int freeBytes;

  const StorageInfo({
    required this.totalBytes,
    required this.usedBytes,
    required this.freeBytes,
  });

  /// The percentage of storage used (0.0 to 1.0).
  double get usedPercentage {
    if (totalBytes == 0) return 0.0;
    return usedBytes / totalBytes;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Formatted total storage size.
  String get formattedTotal => _formatBytes(totalBytes);

  /// Formatted used storage size.
  String get formattedUsed => _formatBytes(usedBytes);

  /// Formatted free storage size.
  String get formattedFree => _formatBytes(freeBytes);
}

/// Repository for querying storage information.
class StorageRepository {
  final NativePlatformService _platformService;

  const StorageRepository(this._platformService);

  /// Retrieves storage info from the native platform.
  Future<StorageInfo> getStorageInfo() async {
    final stats = await _platformService.getStorageInfo();

    final total = stats['totalBytes'] ?? 0;
    final free = stats['freeBytes'] ?? 0;
    final used = stats['usedBytes'] ?? (total - free);

    return StorageInfo(
      totalBytes: total,
      usedBytes: used,
      freeBytes: free,
    );
  }
}
