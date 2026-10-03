import re

with open("lib/presentation/screens/inbox/inbox_screen.dart", "r") as f:
    content = f.read()

content = content.replace("package:free_space/data/models/tracked_item.dart", "package:free_space/data/models/tracked_item_model.dart")

with open("lib/presentation/screens/inbox/inbox_screen.dart", "w") as f:
    f.write(content)

