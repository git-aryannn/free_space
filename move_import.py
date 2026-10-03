import re

with open("lib/data/services/background_live_service.dart", "r") as f:
    content = f.read()

content = content.replace("\nimport 'package:workmanager/workmanager.dart';", "")
content = "import 'package:workmanager/workmanager.dart';\n" + content

with open("lib/data/services/background_live_service.dart", "w") as f:
    f.write(content)
