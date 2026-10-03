import re

with open("lib/data/repositories/item_repository.dart", "r") as f:
    content = f.read()

replacement = '''
  Future<void> trackNewFile(String path, ItemCategory category, String name) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return;
      
      final stat = await file.stat();
      final type = _determineType(path);
      
      final item = TrackedItemsCompanion.insert(
        name: name,
        path: path,
        type: type,
        sizeBytes: drift.Value(stat.size),
        category: category,
        createdAt: DateTime.now(),
        lastUsedAt: DateTime.now(),
        temporarySince: drift.Value(category == ItemCategory.temporary ? DateTime.now() : null),
      );
      
      await _dao.upsertItem(item);
    } catch (e) {
      developer.log('Error tracking new file: $e');
    }
  }

  ItemType _determineType(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return ItemType.image;
    if (['mp4', 'mkv', 'avi', 'mov'].contains(ext)) return ItemType.video;
    if (['mp3', 'wav', 'aac', 'flac'].contains(ext)) return ItemType.audio;
    if (['pdf', 'doc', 'docx', 'txt'].contains(ext)) return ItemType.document;
    if (['apk', 'aab'].contains(ext)) return ItemType.app;
    return ItemType.other;
  }
}
'''

content = re.sub(r'\}\s*$', replacement, content)

with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(content)

