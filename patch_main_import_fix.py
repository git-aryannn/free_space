import re

with open("lib/main.dart", "r") as f:
    content = f.read()

content = content.replace("import 'package:free_space/presentation/providers/service_providers.dart';", "import 'package:free_space/presentation/providers/items_provider.dart';")

with open("lib/main.dart", "w") as f:
    f.write(content)

