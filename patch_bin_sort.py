import re

with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

target = r"""        body: binItemsAsync\.when\(
          data: \(items\) \{
            final trackedTrashPaths = items
                \.map\(\(item\) => item\.systemTrashPath\)"""

replacement = r"""        body: binItemsAsync.when(
          data: (unsortedItems) {
            final items = List.of(unsortedItems);
            items.sort((a, b) => (a.trashedAt ?? a.startDay).compareTo(b.trashedAt ?? b.startDay));
            final trackedTrashPaths = items
                .map((item) => item.systemTrashPath)"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
