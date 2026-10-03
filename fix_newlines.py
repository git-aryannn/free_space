with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

content = content.replace("Text('Smart Sync\n(On open)'", r"Text('Smart Sync\n(On open)'")
content = content.replace("Text('Efficient\n(Background)'", r"Text('Efficient\n(Background)'")
content = content.replace("Text('Live Mode\n(Instant)'", r"Text('Live Mode\n(Instant)'")

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
