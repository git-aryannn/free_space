import re

with open("lib/main.dart", "r") as f:
    content = f.read()

content = content.replace("void main() async {", "void main() async {\n  FlutterError.onError = (details) { print('FLUTTER ERROR: ${details.exceptionAsString()}'); };")

with open("lib/main.dart", "w") as f:
    f.write(content)
