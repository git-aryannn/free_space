import re

with open("lib/main.dart", "r") as f:
    content = f.read()

target = r'''  final container = ProviderContainer\(\);
  final notificationService = NotificationService\('''

replacement = '''  late final NotificationService notificationService;
  final container = ProviderContainer(
    overrides: [
      notificationServiceProvider.overrideWith((ref) => notificationService),
    ],
  );
  notificationService = NotificationService('''

content = re.sub(target, replacement, content)

# Add imports for ItemRepository and ItemCategory if missing
if "import 'package:free_space/data/models/item_enums.dart';" not in content:
    content = "import 'package:free_space/data/models/item_enums.dart';\n" + content
if "import 'package:free_space/data/repositories/item_repository.dart';" not in content:
    content = "import 'package:free_space/data/repositories/item_repository.dart';\n" + content

with open("lib/main.dart", "w") as f:
    f.write(content)

