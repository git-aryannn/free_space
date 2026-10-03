import re

with open("lib/data/services/sync_service.dart", "r") as f:
    content = f.read()
if "import 'package:free_space/presentation/providers/storage_provider.dart';" not in content:
    content = "import 'package:free_space/presentation/providers/storage_provider.dart';\n" + content
with open("lib/data/services/sync_service.dart", "w") as f:
    f.write(content)

with open("lib/presentation/screens/inbox/inbox_screen.dart", "r") as f:
    content = f.read()
if "import 'package:free_space/presentation/providers/storage_provider.dart';" not in content:
    content = "import 'package:free_space/presentation/providers/storage_provider.dart';\n" + content
with open("lib/presentation/screens/inbox/inbox_screen.dart", "w") as f:
    f.write(content)
