import re

with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

target = r"""    final filteredItems = availableItems\.where\(\(item\) \{
      return switch \(currentFilter\) \{
        ItemFilter\.all => true,
        ItemFilter\.media => item\.type == ItemType\.media,
        ItemFilter\.files => item\.type == ItemType\.file,
        ItemFilter\.apps => item\.type == ItemType\.app,
      \};
    \}\);
    final allVisibleSelected = filteredItems\.isNotEmpty &&
        filteredItems\.every\(\(item\) => _selectedIds\.contains\(item\.id\)\);"""

replacement = r"""    final filteredItems = availableItems.where((item) {
      return switch (currentFilter) {
        ItemFilter.all => true,
        ItemFilter.media => item.type == ItemType.media,
        ItemFilter.files => item.type == ItemType.file,
        ItemFilter.apps => item.type == ItemType.app,
      };
    }).toList();
    
    filteredItems.sort((a, b) {
      switch (currentSort) {
        case ItemSort.daysUnused:
          return a.daysUntilBinned(inactivityDays).compareTo(b.daysUntilBinned(inactivityDays));
        case ItemSort.size:
          return b.sizeBytes.compareTo(a.sizeBytes);
        case ItemSort.name:
          return a.name.compareTo(b.name);
      }
    });

    final allVisibleSelected = filteredItems.isNotEmpty &&
        filteredItems.every((item) => _selectedIds.contains(item.id));"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
