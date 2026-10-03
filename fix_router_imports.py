with open("lib/core/router/app_router.dart", "r") as f:
    content = f.read()
content = content.replace("import 'package:free_space/presentation/screens/settings/settings_screen.dart';", "import 'package:free_space/presentation/screens/settings/settings_screen.dart';\nimport 'package:free_space/presentation/screens/inbox/inbox_screen.dart';")
with open("lib/core/router/app_router.dart", "w") as f:
    f.write(content)
