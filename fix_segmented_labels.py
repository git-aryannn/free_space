import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

# Replace \n and anything inside parenthesis if any? No, let's just make it single line text
# and ensure maxLines: 1
def replace_labels(match):
    full_text = match.group(0)
    # Remove \n and make maxLines: 1
    # Example: 'Smart Sync\\n(On open)' -> 'Smart Sync (On open)'
    # Or just 'Smart Sync' if it's too long? Let's keep it 'Smart Sync (On open)'
    replaced = full_text.replace("\\n", " ").replace("maxLines: 2", "maxLines: 1")
    return replaced

content = re.sub(r"FittedBox\(fit: BoxFit\.scaleDown, child: Text\('[^']+', [^\)]+\)\)", replace_labels, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
