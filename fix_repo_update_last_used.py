import re
with open("lib/data/repositories/item_repository.dart", "r") as f:
    content = f.read()

target = r"""  Future<void> restore\(int id\) async \{
    await categorizeMany\(\[id\], ItemCategory\.temporary\);
  \}"""

replacement = r"""  Future<void> restore(int id) async {
    await categorizeMany([id], ItemCategory.temporary);
  }

  /// Updates the last used timestamp for an item.
  Future<void> updateLastUsed(int id, DateTime lastUsed) async {
    await _dao.updateLastUsed(id, lastUsed);
  }"""
content = re.sub(target, replacement, content)

with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(content)
