import re

with open("lib/data/database/app_database.dart", "r") as f:
    content = f.read()

target = r'''  Future<List<TrackedItem>> getItemsPage\(\{
    required ItemCategory category,
    required ItemSort sort,
    required int limit,
    required int offset,
    ItemType\? type,
    String\? search,
  \}\) \{
    final normalizedSearch = search\?\.trim\(\) \?\? '';
    final query = select\(trackedItems\)
      \.\.where\(
        \(row\) =>
            row\.category\.equals\(category\.name\) &
            \(type == null \? const Constant\(true\) : row\.type\.equals\(type\.name\)\) &
            \(normalizedSearch\.isEmpty
                \? const Constant\(true\)
                : row\.name\.contains\(normalizedSearch\)\),
      \)'''

replacement = '''  Future<List<TrackedItem>> getItemsPage({
    required ItemCategory category,
    required ItemSort sort,
    required int limit,
    required int offset,
    ItemType? type,
    String? search,
    String? rootPath,
  }) {
    final normalizedSearch = search?.trim() ?? '';
    final query = select(trackedItems)
      ..where(
        (row) =>
            row.category.equals(category.name) &
            (type == null ? const Constant(true) : row.type.equals(type.name)) &
            (normalizedSearch.isEmpty
                ? const Constant(true)
                : row.name.contains(normalizedSearch)) &
            (rootPath == null || rootPath.isEmpty
                ? const Constant(true)
                : row.originalPath.like('$rootPath%')),
      )'''

content = re.sub(target, replacement, content)

with open("lib/data/database/app_database.dart", "w") as f:
    f.write(content)

