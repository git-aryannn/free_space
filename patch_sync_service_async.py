import re

with open("lib/data/services/sync_service.dart", "r") as f:
    content = f.read()

target = r'''    for \(final folder in foldersToScan\) \{
      final dir = Directory\(folder\);
      if \(!dir\.existsSync\(\)\) continue;

      try \{
        for \(final entity in dir\.listSync\(recursive: true, followLinks: false\)\) \{
          if \(entity is File\) \{
            try \{
              final stat = entity\.statSync\(\);
              // Skip files modified before the last sync
              if \(stat\.modified\.isBefore\(lastSync\)\) continue;
              
              // Skip if already tracked
              if \(trackedPaths\.contains\(entity\.path\)\) continue;
              
              // Skip hidden files or app bin files
              if \(p\.basename\(entity\.path\)\.startsWith\('\.'\)\) continue;
              if \(entity\.path\.contains\('\.FreeSpaceBin'\)\) continue;

              final name = p\.basename\(entity\.path\);
              newItems\.add\(
                TrackedItemModel\(
                  id: 0,
                  path: entity\.path,
                  name: name,
                  sizeBytes: stat\.size,
                  category: ItemCategory\.permanent,
                  lastUsedAt: stat\.modified,
                  type: ItemType\.file,
                  createdAt: stat\.modified,
                  isFlagged: false,
                \),
              \);
            \} catch \(_\) \{\}
          \}
        \}
      \} catch \(_\) \{\}
    \}'''

replacement = r'''    for (final folder in foldersToScan) {
      final dir = Directory(folder);
      if (!await dir.exists()) continue;

      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            try {
              final stat = await entity.stat();
              // Skip files modified before the last sync
              if (stat.modified.isBefore(lastSync)) continue;
              
              // Skip if already tracked
              if (trackedPaths.contains(entity.path)) continue;
              
              // Skip hidden files or app bin files
              if (p.basename(entity.path).startsWith('.')) continue;
              if (entity.path.contains('.FreeSpaceBin')) continue;

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
    }'''

content = re.sub(target, replacement, content)

with open("lib/data/services/sync_service.dart", "w") as f:
    f.write(content)
