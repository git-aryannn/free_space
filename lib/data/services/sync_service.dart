import 'package:free_space/presentation/providers/storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/data/repositories/settings_repository.dart';
import 'package:free_space/presentation/providers/items_provider.dart';
import 'package:free_space/data/services/native_platform_service.dart';
import 'package:free_space/presentation/providers/inbox_provider.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class SyncService {
  final Ref ref;

  SyncService(this.ref);

  Future<void> performSync({bool force = false}) async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final itemRepo = ref.read(itemRepositoryProvider);
    final nativeService = ref.read(nativePlatformServiceProvider);

    if (!force) {
      final mode = await settingsRepo.getDetectionMode();
      if (mode != DetectionMode.smartSync) {
        return; // Only sync on open in Smart Sync mode
      }
    }

    final hasAccess = await nativeService.hasAllFilesAccess();
    if (!hasAccess) return;

    final rootPath = await nativeService.getExternalStorageRootPath();
    final foldersToScan = [
      p.join(rootPath, 'Downloads'),
      p.join(rootPath, 'Download'), // Some devices use Download
      p.join(rootPath, 'DCIM'),
      p.join(rootPath, 'Pictures'),
      p.join(rootPath, 'Movies'),
    ];

    DateTime? lastSync = await settingsRepo.getLastSyncTime();

    // If first time syncing, let's just use "now" so we don't overwhelm the user with thousands of old files.
    // Or we could use DateTime.now().subtract(1 day). Let's use 1 hour ago for the very first time.
    if (lastSync == null) {
      lastSync = DateTime.now().subtract(const Duration(hours: 1));
      await settingsRepo.setLastSyncTime(DateTime.now());
    }

    final newSyncTime = DateTime.now();
    final List<TrackedItemModel> newItems = [];

    // Get currently tracked items to avoid duplicates
    final trackedItems = await itemRepo.getAllItems();
    final trackedPaths = trackedItems.map((e) => e.path).toSet();

    for (final folder in foldersToScan) {
      final dir = Directory(folder);
      if (!await dir.exists()) continue;

      try {
        await for (final entity
            in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            try {
              final stat = await entity.stat();
              // Skip files modified before the last sync
              if (stat.modified.isBefore(lastSync)) continue;

              // Skip if already tracked
              if (trackedPaths.contains(entity.path)) continue;

              // Skip hidden files or app bin files
              if (p.basename(entity.path).startsWith('.')) continue;
              if (entity.path.contains('.FreeSpaceBin') ||
                  entity.path.contains('Free Space Bin')) continue;

              final name = p.basename(entity.path);
              newItems.add(
                TrackedItemModel(
                  id: 0,
                  path: entity.path,
                  name: name,
                  sizeBytes: stat.size,
                  category: ItemCategory.permanent,
                  lastUsedAt: stat.modified,
                  type: ItemType.file,
                  createdAt: stat.modified,
                  isFlagged: false,
                ),
              );
            } catch (_) {}
          }
        }
      } catch (_) {}
    }

    if (newItems.isNotEmpty) {
      ref.read(inboxProvider.notifier).addItems(newItems);
    }

    await settingsRepo.setLastSyncTime(newSyncTime);
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});
