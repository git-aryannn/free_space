with open("pubspec.yaml", "r") as f:
    content = f.read()

content = content.replace("ios: true", "ios: false")

with open("pubspec.yaml", "w") as f:
    f.write(content)

