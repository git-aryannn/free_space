import re
with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

if "package:flutter_background_service/flutter_background_service.dart" not in content:
    content = content.replace("import 'package:flutter_riverpod/flutter_riverpod.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:flutter_background_service/flutter_background_service.dart';")
    with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
        f.write(content)
