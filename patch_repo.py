import re

with open("lib/data/repositories/item_repository.dart", "r") as f:
    content = f.read()

target = r'''  Stream<int> watchPermanentCount\(\) \{
    return _dao\.watchCountByCategory\('permanent'\);
  \}'''

replacement = '''  Stream<int> watchPermanentCountByRoot(String? rootPath) {
    return _dao.watchCountByCategory('permanent', rootPath: rootPath);
  }'''

content = re.sub(target, replacement, content)

with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(content)

