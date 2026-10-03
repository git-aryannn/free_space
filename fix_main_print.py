import re

with open("lib/main.dart", "r") as f:
    content = f.read()

content = content.replace("void main() async {", "void main() async {\n  print('APP START: ensureInitialized');")
content = content.replace("await initializeBackgroundService();", "print('APP START: initializeBackgroundService');\n  await initializeBackgroundService();")
content = content.replace("await initializeWorkManager();", "print('APP START: initializeWorkManager');\n  await initializeWorkManager();")
content = content.replace("final container = ProviderContainer(", "print('APP START: Setting up ProviderContainer');\n  final container = ProviderContainer(")
content = content.replace("final mode = await settingsRepo.getDetectionMode();", "print('APP START: getDetectionMode');\n  final mode = await settingsRepo.getDetectionMode();")
content = content.replace("runApp(", "print('APP START: runApp');\n  runApp(")

with open("lib/main.dart", "w") as f:
    f.write(content)
