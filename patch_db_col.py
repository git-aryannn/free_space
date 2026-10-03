import re

with open("lib/data/database/app_database.dart", "r") as f:
    content = f.read()

content = content.replace("row.originalPath.like", "row.path.like")

with open("lib/data/database/app_database.dart", "w") as f:
    f.write(content)

