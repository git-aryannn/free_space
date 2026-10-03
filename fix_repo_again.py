with open("lib/data/repositories/settings_repository.dart", "r") as f:
    content = f.read()

content = content.replace("import 'package:flutter/material.dart';\n\nenum DetectionMode { smartSync, liveMonitoring }\nimport 'package:free_space/data/database/app_database.dart';", "import 'package:flutter/material.dart';\nimport 'package:free_space/data/database/app_database.dart';\n\nenum DetectionMode { smartSync, liveMonitoring }")

with open("lib/data/repositories/settings_repository.dart", "w") as f:
    f.write(content)
