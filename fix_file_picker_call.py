import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

content = content.replace("await FilePicker.platform.getDirectoryPath(", "await FilePicker.getDirectoryPath(")

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
