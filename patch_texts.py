import re

def patch_file(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    content = content.replace("'Show in file manager'", "'Open/View'")

    with open(filepath, "w") as f:
        f.write(content)

patch_file("lib/presentation/widgets/tracked_item_actions.dart")
patch_file("lib/presentation/screens/bin/bin_screen.dart")

