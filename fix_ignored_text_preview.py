with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = """        final currentValueText = pathsCount == 0
            ? 'Not selected'
            : (pathsCount == 1 ? pathsList.first : '$pathsCount folders');"""

replacement = """        final currentValueText = pathsCount == 0 ? 'Not selected' : '$pathsCount selected';"""

content = content.replace(target, replacement)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
