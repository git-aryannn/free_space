import os

files = [
    "lib/presentation/providers/inbox_provider.dart",
    "lib/data/services/sync_service.dart",
    "lib/presentation/screens/inbox/inbox_screen.dart"
]

for filepath in files:
    with open(filepath, "r") as f:
        content = f.read()
    
    content = content.replace("TrackedItem", "TrackedItemModel")
    
    with open(filepath, "w") as f:
        f.write(content)

