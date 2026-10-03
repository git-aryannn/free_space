import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

# Replace Text inside SegmentedButton for DetectionMode
target = r'''                            ButtonSegment\(
                              value: DetectionMode\.smartSync,
                              label: Text\('Smart Sync\\n\(On open\)', textAlign: TextAlign\.center, style: TextStyle\(fontSize: 11\)\),
                              icon: Icon\(Icons\.sync\),
                            \),
                            ButtonSegment\(
                              value: DetectionMode\.efficientBackground,
                              label: Text\('Efficient\\n\(Background\)', textAlign: TextAlign\.center, style: TextStyle\(fontSize: 11\)\),
                              icon: Icon\(Icons\.schedule\),
                            \),
                            ButtonSegment\(
                              value: DetectionMode\.liveMonitoring,
                              label: Text\('Live Mode\\n\(Instant\)', textAlign: TextAlign\.center, style: TextStyle\(fontSize: 11\)\),
                              icon: Icon\(Icons\.flash_on\),
                            \),'''

replacement = r'''                            ButtonSegment(
                              value: DetectionMode.smartSync,
                              label: FittedBox(fit: BoxFit.scaleDown, child: Text('Smart Sync\n(On open)', textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: 11))),
                              icon: Icon(Icons.sync),
                            ),
                            ButtonSegment(
                              value: DetectionMode.efficientBackground,
                              label: FittedBox(fit: BoxFit.scaleDown, child: Text('Efficient\n(Background)', textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: 11))),
                              icon: Icon(Icons.schedule),
                            ),
                            ButtonSegment(
                              value: DetectionMode.liveMonitoring,
                              label: FittedBox(fit: BoxFit.scaleDown, child: Text('Live Mode\n(Instant)', textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: 11))),
                              icon: Icon(Icons.flash_on),
                            ),'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
