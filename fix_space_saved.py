import re
with open("lib/data/database/app_database.dart", "r") as f:
    content = f.read()

target = r"""  Future<void> removeIgnoredPath\(String path\) async \{"""
replacement = r"""  Future<int> getTotalSpaceSaved() async {
    final value = await getSetting('total_space_saved');
    return int.tryParse(value ?? '0') ?? 0;
  }

  Future<void> addSpaceSaved(int bytes) async {
    if (bytes <= 0) return;
    final current = await getTotalSpaceSaved();
    await setSetting('total_space_saved', (current + bytes).toString());
  }

  Future<void> removeIgnoredPath(String path) async {"""
content = re.sub(target, replacement, content)
with open("lib/data/database/app_database.dart", "w") as f:
    f.write(content)

with open("lib/data/repositories/item_repository.dart", "r") as f:
    content = f.read()

# in _permanentlyDeleteBinnedItems
target2 = r"""    await _dao.deleteItems\(deletedItemList\.map\(\(item\) => item\.id\)\.toList\(\)\);"""
replacement2 = r"""    await _dao.deleteItems(deletedItemList.map((item) => item.id).toList());
    
    // Add space saved
    int bytesSaved = 0;
    for (final item in deletedItemList) {
      bytesSaved += item.sizeBytes;
    }
    if (bytesSaved > 0) {
      await _dao.addSpaceSaved(bytesSaved);
    }"""
content = re.sub(target2, replacement2, content)

# in deleteMany (if nonBinned items are deleted)
target3 = r"""      await _dao\.deleteItems\(nonBinnedIds\);"""
replacement3 = r"""      await _dao.deleteItems(nonBinnedIds);
      
      int bytesSaved = 0;
      for (final item in items.where((i) => nonBinnedIds.contains(i.id))) {
        bytesSaved += item.sizeBytes;
      }
      if (bytesSaved > 0) {
        await _dao.addSpaceSaved(bytesSaved);
      }"""
content = re.sub(target3, replacement3, content)

with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(content)
