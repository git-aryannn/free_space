with open("lib/presentation/providers/inbox_provider.dart", "r") as f:
    content = f.read()

content = content.replace("import 'package:free_space/data/repositories/settings_repository.dart';\nimport 'package:free_space/presentation/providers/settings_provider.dart';", "")
content = "import 'package:free_space/data/repositories/settings_repository.dart';\nimport 'package:free_space/presentation/providers/settings_provider.dart';\n" + content

with open("lib/presentation/providers/inbox_provider.dart", "w") as f:
    f.write(content)
