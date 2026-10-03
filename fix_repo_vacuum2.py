import re
with open("lib/data/repositories/item_repository.dart", "r") as f:
    content = f.read()

target = r"""    final binnedIds = binnedItems\.map\(\(item\) => item\.id\)\.toSet\(\);
    await _dao\.deleteItems\(ids\.where\(\(id\) => !binnedIds\.contains\(id\)\)\.toList\(\)\);
  \}"""

replacement = r"""    final binnedIds = binnedItems.map((item) => item.id).toSet();
    final nonBinnedIds = ids.where((id) => !binnedIds.contains(id)).toList();
    if (nonBinnedIds.isNotEmpty) {
      await _dao.deleteItems(nonBinnedIds);
      try {
        await _dao.vacuumDatabase();
      } catch (_) {}
    }
  }"""
content = re.sub(target, replacement, content)

with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(content)
