import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

content = content.replace("context.go('/');", "context.pop();")

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)

