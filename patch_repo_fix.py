import re

with open("lib/data/repositories/item_repository.dart", "r") as f:
    content = f.read()

content = content.replace("_dao.upsertItem(item)", "_dao.insertItem(item)")

with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(content)

