import re
with open("lib/data/services/system_file_scan_service.dart", "r") as f:
    content = f.read()

# in processEntity
target_process = r"""    Future<void> processEntity\(FileSystemEntity entity\) async \{
      if \(visitedPaths\.contains\(entity\.path\)\) return;
      visitedPaths\.add\(entity\.path\);"""

replacement_process = r"""    Future<void> processEntity(FileSystemEntity entity) async {
      if (visitedPaths.contains(entity.path)) return;
      
      // Check if path is in ignoredPaths
      final isIgnored = ignoredPaths.any((ignoredPath) => 
        entity.path == ignoredPath || entity.path.startsWith('$ignoredPath/'));
      if (isIgnored) return;

      visitedPaths.add(entity.path);"""
content = re.sub(target_process, replacement_process, content)

# in _scanDocumentTree loop
target_tree = r"""    for \(final entry in entries\) \{
      final name = entry\['name'\] as String;
      final path = entry\['uri'\] as String;
      final sizeBytes = \(entry\['sizeBytes'\] as num\)\.toInt\(\);
      final modifiedAt =
          DateTime\.fromMillisecondsSinceEpoch\(\(entry\['lastModified'\] as num\)\.toInt\(\)\);"""

replacement_tree = r"""    for (final entry in entries) {
      final name = entry['name'] as String;
      final path = entry['uri'] as String;
      
      // For Android MediaStore / content URIs, the ignoredPaths might be full display paths,
      // but let's try to match by name as a simple fallback if path contains it.
      final isIgnored = ignoredPaths.any((ignoredPath) {
        if (path == ignoredPath) return true;
        // Basic match for Android paths (e.g. "WhatsApp Images" inside path)
        if (path.toLowerCase().contains(ignoredPath.toLowerCase().replaceAll('/', '%2F'))) return true;
        // Direct string match if ignoredPath is a keyword
        if (path.toLowerCase().contains(ignoredPath.toLowerCase())) return true;
        return false;
      });
      if (isIgnored) continue;
      
      final sizeBytes = (entry['sizeBytes'] as num).toInt();
      final modifiedAt =
          DateTime.fromMillisecondsSinceEpoch((entry['lastModified'] as num).toInt());"""
content = re.sub(target_tree, replacement_tree, content)

with open("lib/data/services/system_file_scan_service.dart", "w") as f:
    f.write(content)
