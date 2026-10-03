import re

with open("lib/presentation/widgets/item_action_helpers.dart", "r") as f:
    content = f.read()

target = r"""  // Update last access time since the user just interacted with the file
  await ref
      \.read\(itemRepositoryProvider\)
      \.updateLastUsed\(item\.id, DateTime\.now\(\)\);
  _refreshItemLists\(ref\);"""

content = re.sub(target, "  // Removed updateLastUsed to keep timer intact when merely viewing.", content)

with open("lib/presentation/widgets/item_action_helpers.dart", "w") as f:
    f.write(content)
