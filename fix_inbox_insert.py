with open("lib/presentation/screens/inbox/inbox_screen.dart", "r") as f:
    content = f.read()
content = content.replace("itemRepo.insertItem(newItem);", "itemRepo.addItem(newItem);")
with open("lib/presentation/screens/inbox/inbox_screen.dart", "w") as f:
    f.write(content)
