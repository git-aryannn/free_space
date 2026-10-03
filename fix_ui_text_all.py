import re

# settings_screen.dart
with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

# Fix OperationMode in settings_screen.dart
content = content.replace("label: Text('Review first'),", "label: FittedBox(fit: BoxFit.scaleDown, child: Text('Review first')),")
content = content.replace("label: Text('Auto-bin'),", "label: FittedBox(fit: BoxFit.scaleDown, child: Text('Auto-bin')),")

# Fix ThemeMode in settings_screen.dart
content = content.replace("label: Text('System'),", "label: FittedBox(fit: BoxFit.scaleDown, child: Text('System')),")
content = content.replace("label: Text('Light'),", "label: FittedBox(fit: BoxFit.scaleDown, child: Text('Light')),")
content = content.replace("label: Text('Dark'),", "label: FittedBox(fit: BoxFit.scaleDown, child: Text('Dark')),")

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)

# mode_toggle.dart
with open("lib/presentation/widgets/mode_toggle.dart", "r") as f:
    content = f.read()

content = content.replace("label: Text('Auto-Bin'),", "label: FittedBox(fit: BoxFit.scaleDown, child: Text('Auto-Bin', maxLines: 1)),")
content = content.replace("label: Text('Hold & Review'),", "label: FittedBox(fit: BoxFit.scaleDown, child: Text('Hold & Review', maxLines: 1)),")

with open("lib/presentation/widgets/mode_toggle.dart", "w") as f:
    f.write(content)
