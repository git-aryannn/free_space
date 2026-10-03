import re

with open("lib/presentation/screens/home/home_shell.dart", "r") as f:
    content = f.read()

# Add sync_service.dart import
if "import 'package:free_space/data/services/sync_service.dart';" not in content:
    content = content.replace(
        "import 'package:free_space/data/models/tracked_item_model.dart';",
        "import 'package:free_space/data/models/tracked_item_model.dart';\nimport 'package:free_space/data/services/sync_service.dart';"
    )

target = r'''  void didChangeAppLifecycleState\(AppLifecycleState state\) \{
    if \(state == AppLifecycleState\.resumed\) _purgeExpiredItems\(\);
  \}'''

replacement = r'''  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _purgeExpiredItems();
      ref.read(syncServiceProvider).performSync();
    }
  }'''

content = re.sub(target, replacement, content)

target_init = r'''    WidgetsBinding\.instance\.addObserver\(this\);
    _purgeExpiredItems\(\);'''

replacement_init = r'''    WidgetsBinding.instance.addObserver(this);
    _purgeExpiredItems();
    ref.read(syncServiceProvider).performSync();'''

content = re.sub(target_init, replacement_init, content)

with open("lib/presentation/screens/home/home_shell.dart", "w") as f:
    f.write(content)

