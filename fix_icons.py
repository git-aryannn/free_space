with open("pubspec.yaml", "r") as f:
    content = f.read()

content = content.replace("flutter_launcher_icons:", "flutter_icons:")

with open("pubspec.yaml", "w") as f:
    f.write(content)

