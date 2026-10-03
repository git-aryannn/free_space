import re

with open("lib/data/services/background_live_service.dart", "r") as f:
    content = f.read()

content = content.replace("await itemRepo.getAllItems()", "await settingsRepo.getInboxItems()")

with open("lib/data/services/background_live_service.dart", "w") as f:
    f.write(content)
