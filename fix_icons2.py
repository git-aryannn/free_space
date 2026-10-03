with open("pubspec.yaml", "r") as f:
    content = f.read()

content = content.replace("  flutter_icons: ^0.9.3", "  flutter_launcher_icons: ^0.9.3")

with open("pubspec.yaml", "w") as f:
    f.write(content)

