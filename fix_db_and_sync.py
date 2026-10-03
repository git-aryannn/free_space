import re

with open("lib/data/database/app_database.dart", "r") as f:
    content = f.read()

content = content.replace("Future<int> insertItem(TrackedItemsCompanion item) =>\n      into(trackedItems).insert(item);", "Future<int> insertItem(TrackedItemsCompanion item) =>\n      into(trackedItems).insert(item, mode: InsertMode.insertOrReplace);")

with open("lib/data/database/app_database.dart", "w") as f:
    f.write(content)

with open("lib/data/services/sync_service.dart", "r") as f:
    content = f.read()

content = content.replace("if (entity.path.contains('.FreeSpaceBin')) continue;", "if (entity.path.contains('.FreeSpaceBin') || entity.path.contains('Free Space Bin')) continue;")

with open("lib/data/services/sync_service.dart", "w") as f:
    f.write(content)
