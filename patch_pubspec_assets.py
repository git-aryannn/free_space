import re

with open("pubspec.yaml", "r") as f:
    content = f.read()

# Make sure we add assets under flutter:
target = r'''flutter:
  uses-material-design: true'''

replacement = '''flutter:
  uses-material-design: true
  assets:
    - assets/images/'''

content = re.sub(target, replacement, content)

with open("pubspec.yaml", "w") as f:
    f.write(content)

