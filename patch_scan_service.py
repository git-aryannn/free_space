import re

with open("lib/data/services/system_file_scan_service.dart", "r") as f:
    content = f.read()

target = r'''    for \(final path in paths\) \{
      final entityType = await FileSystemEntity\.type\(path, followLinks: true\);
      if \(entityType == FileSystemEntityType\.notFound\) \{
        throw FileSystemException\('Selected item does not exist', path\);
      \}'''

replacement = '''    for (var path in paths) {
      try {
        path = File(path).resolveSymbolicLinksSync();
      } catch (_) {}
      
      final entityType = await FileSystemEntity.type(path, followLinks: true);
      if (entityType == FileSystemEntityType.notFound) {
        throw FileSystemException('Selected item does not exist', path);
      }'''

content = re.sub(target, replacement, content)

with open("lib/data/services/system_file_scan_service.dart", "w") as f:
    f.write(content)

