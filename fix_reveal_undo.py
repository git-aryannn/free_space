import re
with open("lib/presentation/widgets/item_action_helpers.dart", "r") as f:
    content = f.read()

target = r"""  if \(!opened\) \{
    throw StateError\('The file manager could not reveal this item\.'\);
  \}
  
  // Update last access time since the user just interacted with the file
  await ref\.read\(itemRepositoryProvider\)\.updateLastUsed\(item\.id, DateTime\.now\(\)\);
  _refreshItemLists\(ref\);
\}"""

replacement = r"""  if (!opened) {
    throw StateError('The file manager could not reveal this item.');
  }
}"""
content = re.sub(target, replacement, content)

with open("lib/presentation/widgets/item_action_helpers.dart", "w") as f:
    f.write(content)
