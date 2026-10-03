with open("lib/presentation/screens/inbox/inbox_screen.dart", "r") as f:
    content = f.read()

content = content.replace("ref.invalidate(permanentItemsProvider);", "ref.invalidate(permanentItemsRevisionProvider);")

with open("lib/presentation/screens/inbox/inbox_screen.dart", "w") as f:
    f.write(content)
