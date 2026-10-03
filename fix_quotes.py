with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

content = content.replace("Text('Smart Sync\n(Battery Saver)'", "Text('Smart Sync\\n(Battery Saver)'")
content = content.replace("Text('Live Mode\n(Instant)'", "Text('Live Mode\\n(Instant)'")

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
