import re

with open("lib/main.dart", "r") as f:
    content = f.read()

if "import 'package:free_space/presentation/providers/notification_provider.dart';" not in content:
    content = "import 'package:free_space/presentation/providers/notification_provider.dart';\n" + content

with open("lib/main.dart", "w") as f:
    f.write(content)

