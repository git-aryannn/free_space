import re

with open("lib/data/repositories/item_repository.dart", "r") as f:
    content = f.read()

content = content.replace("import 'dart:io' show Platform;", "import 'dart:io';")
if "import 'package:drift/drift.dart' as drift;" not in content:
    content = "import 'package:drift/drift.dart' as drift;\n" + content

with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(content)

