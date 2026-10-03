import re
with open("lib/data/repositories/item_repository.dart", "r") as f:
    content = f.read()

content = content.replace("await _dao.addSpaceSaved(bytesSaved);", "await (_dao.attachedDatabase as AppDatabase).appSettingsDao.addSpaceSaved(bytesSaved);")

# Also we need to import AppDatabase in ItemRepository if not already
if "import 'package:free_space/data/database/app_database.dart';" not in content:
    content = content.replace("import 'package:free_space/data/models/tracked_item_model.dart';", "import 'package:free_space/data/models/tracked_item_model.dart';\nimport 'package:free_space/data/database/app_database.dart';")

with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(content)
