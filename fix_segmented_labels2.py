import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

def ensure_max_lines(match):
    text_content = match.group(1)
    if 'maxLines' not in text_content:
        # insert maxLines: 1
        return f"FittedBox(fit: BoxFit.scaleDown, child: Text({text_content}, maxLines: 1))"
    return match.group(0)

content = re.sub(r"FittedBox\(fit: BoxFit\.scaleDown, child: Text\(([^)]+)\)\)", ensure_max_lines, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
