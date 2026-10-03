import re
with open("lib/data/database/app_database.dart", "r") as f:
    content = f.read()

target = r"""  Stream<int> watchCountByCategory\(String categoryName, \{String\? rootPath\}\) \{
    final category =
        ItemCategory\.values\.firstWhere\(\(e\) => e\.name == categoryName\);
    final count = trackedItems\.id\.count\(\);
    final query = selectOnly\(trackedItems\)
      \.\.addColumns\(\[count\]\)
      \.\.where\(trackedItems\.category\.equals\(category\.name\) &
          \(rootPath == null \|\| rootPath\.isEmpty
              \? const Constant\(true\)
              : trackedItems\.path\.like\('\$rootPath%'\)\)\);
    return query\.map\(\(row\) => row\.read\(count\)!\)\.watchSingle\(\);
  \}
\}"""

replacement = r"""  Stream<int> watchCountByCategory(String categoryName, {String? rootPath}) {
    final category =
        ItemCategory.values.firstWhere((e) => e.name == categoryName);
    final count = trackedItems.id.count();
    final query = selectOnly(trackedItems)
      ..addColumns([count])
      ..where(trackedItems.category.equals(category.name) &
          (rootPath == null || rootPath.isEmpty
              ? const Constant(true)
              : trackedItems.path.like('$rootPath%')));
    return query.map((row) => row.read(count)!).watchSingle();
  }

  /// Compacts and defragments the database
  Future<void> vacuumDatabase() => customStatement('VACUUM');
}"""
content = re.sub(target, replacement, content)

with open("lib/data/database/app_database.dart", "w") as f:
    f.write(content)
