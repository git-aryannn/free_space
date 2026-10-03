import re

with open("lib/data/repositories/item_repository.dart", "r") as f:
    content = f.read()

if "import 'dart:developer' as developer;" not in content:
    content = "import 'dart:developer' as developer;\n" + content

with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(content)

