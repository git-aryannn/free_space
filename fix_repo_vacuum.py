import re
with open("lib/data/repositories/item_repository.dart", "r") as f:
    content = f.read()

target = r"""    final deletedItemList = deletedItems\.toList\(\);
    await _dao\.deleteItems\(deletedItemList\.map\(\(item\) => item\.id\)\.toList\(\)\);
    if \(deletedPaths\.length != paths\.length\) \{"""

replacement = r"""    final deletedItemList = deletedItems.toList();
    await _dao.deleteItems(deletedItemList.map((item) => item.id).toList());
    
    // Compact the SQLite database after bulk deletions to free storage space
    if (deletedItemList.isNotEmpty) {
      try {
        await _dao.vacuumDatabase();
      } catch (_) {}
    }
    
    if (deletedPaths.length != paths.length) {"""
content = re.sub(target, replacement, content)

with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(content)
