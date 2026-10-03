import re

# 1. Fix sync_service.dart imports
with open("lib/data/services/sync_service.dart", "r") as f:
    sync_content = f.read()

sync_content = sync_content.replace(
    "import 'package:free_space/data/models/tracked_item_model.dart\nimport 'package:free_space/data/models/item_enums.dart';';",
    "import 'package:free_space/data/models/tracked_item_model.dart';\nimport 'package:free_space/data/models/item_enums.dart';"
)
with open("lib/data/services/sync_service.dart", "w") as f:
    f.write(sync_content)

# 2. Fix settings_repository.dart enum location
with open("lib/data/repositories/settings_repository.dart", "r") as f:
    repo_content = f.read()

if "enum DetectionMode { smartSync, liveMonitoring }\n\nimport" in repo_content:
    repo_content = repo_content.replace("enum DetectionMode { smartSync, liveMonitoring }\n\nimport 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n\nenum DetectionMode { smartSync, liveMonitoring }")
with open("lib/data/repositories/settings_repository.dart", "w") as f:
    f.write(repo_content)

# 3. Fix inbox_screen.dart constructor
with open("lib/presentation/screens/inbox/inbox_screen.dart", "r") as f:
    inbox_content = f.read()
if "const InboxScreen({super.key});" not in inbox_content:
    inbox_content = inbox_content.replace("class InboxScreen extends ConsumerStatefulWidget {\n", "class InboxScreen extends ConsumerStatefulWidget {\n  const InboxScreen({super.key});\n")
with open("lib/presentation/screens/inbox/inbox_screen.dart", "w") as f:
    f.write(inbox_content)

