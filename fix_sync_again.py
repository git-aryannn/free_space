import re

with open("lib/data/services/sync_service.dart", "r") as f:
    content = f.read()

# Fix repository name
content = content.replace("itemsRepositoryProvider", "itemRepositoryProvider")
content = content.replace("final itemsRepo", "final itemRepo")
content = content.replace("itemsRepo.getAllItems()", "itemRepo.getAllItems()")
if "import 'package:free_space/data/repositories/items_repository.dart';" in content:
    content = content.replace("import 'package:free_space/data/repositories/items_repository.dart';", "import 'package:free_space/presentation/providers/items_provider.dart';")

# Fix TrackedItemModel constructor
target_constructor = r'''                TrackedItemModel\(
                  path: entity\.path,
                  name: name,
                  sizeBytes: stat\.size,
                  category: ItemCategory\.permanent, // Default to permanent, user will decide
                  lastUsedAt: stat\.modified,
                \)'''

replacement_constructor = r'''                TrackedItemModel(
                  id: 0,
                  path: entity.path,
                  name: name,
                  sizeBytes: stat.size,
                  category: ItemCategory.permanent,
                  lastUsedAt: stat.modified,
                  type: ItemType.file,
                  createdAt: stat.modified,
                  isFlagged: false,
                )'''

content = re.sub(target_constructor, replacement_constructor, content)

with open("lib/data/services/sync_service.dart", "w") as f:
    f.write(content)

# Fix inbox screen item repository
with open("lib/presentation/screens/inbox/inbox_screen.dart", "r") as f:
    inbox_content = f.read()

inbox_content = inbox_content.replace("itemsRepositoryProvider", "itemRepositoryProvider")
inbox_content = inbox_content.replace("itemsRepo", "itemRepo")
if "import 'package:free_space/data/repositories/items_repository.dart';" in inbox_content:
    inbox_content = inbox_content.replace("import 'package:free_space/data/repositories/items_repository.dart';", "import 'package:free_space/presentation/providers/items_provider.dart';")

with open("lib/presentation/screens/inbox/inbox_screen.dart", "w") as f:
    f.write(inbox_content)

