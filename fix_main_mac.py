import re

with open("lib/main.dart", "r") as f:
    content = f.read()

content = "import 'dart:io' show Platform;\n" + content
content = content.replace("  import 'dart:io' show Platform;\n  ", "")

with open("lib/main.dart", "w") as f:
    f.write(content)
