import re

with open("lib/main.dart", "r") as f:
    content = f.read()

if "import 'package:free_space/presentation/providers/service_providers.dart';" not in content:
    content = "import 'package:free_space/presentation/providers/service_providers.dart';\n" + content

with open("lib/main.dart", "w") as f:
    f.write(content)

