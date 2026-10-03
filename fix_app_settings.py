import re
with open("lib/data/database/app_database.dart", "r") as f:
    content = f.read()

target = r"""  Stream<String\?> watchSetting\(String key\) \{
    return \(select\(appSettingsTable\)\.\.where\(\(t\) => t\.key\.equals\(key\)\)\)
        \.watchSingleOrNull\(\)
        \.map\(\(row\) => row\?\.value\);
  \}"""

replacement = r"""  Stream<String?> watchSetting(String key) {
    return (select(appSettingsTable)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<List<String>> getIgnoredPaths() async {
    final value = await getSetting('ignored_paths');
    if (value == null || value.isEmpty) return [];
    try {
      import('dart:convert'); // Ensure dart:convert is imported at the top
      return List<String>.from(jsonDecode(value));
    } catch (_) {
      return [];
    }
  }

  Future<void> addIgnoredPath(String path) async {
    final paths = await getIgnoredPaths();
    if (!paths.contains(path)) {
      paths.add(path);
      import('dart:convert');
      await setSetting('ignored_paths', jsonEncode(paths));
    }
  }

  Future<void> removeIgnoredPath(String path) async {
    final paths = await getIgnoredPaths();
    if (paths.contains(path)) {
      paths.remove(path);
      import('dart:convert');
      await setSetting('ignored_paths', jsonEncode(paths));
    }
  }
"""

# Actually we need dart:convert at the top! Let's insert dart:convert.
content = content.replace("import 'package:drift/drift.dart';", "import 'dart:convert';\nimport 'package:drift/drift.dart';")
content = re.sub(target, replacement.replace("import('dart:convert');", ""), content)

with open("lib/data/database/app_database.dart", "w") as f:
    f.write(content)
