import re

with open("lib/main.dart", "r") as f:
    content = f.read()

target = r"""import 'package:flutter/services.dart';
void main\(\) async \{
  FlutterError\.onError = \(details\) \{ print\('FLUTTER ERROR: \$\{details\.exceptionAsString\(\)\}'\); \};
  print\('APP START: ensureInitialized'\);
  WidgetsFlutterBinding\.ensureInitialized\(\);
  try \{
    final channel = MethodChannel\('com.freespace.native'\);
    print\("DEBUG TEST: old root = \$\{await channel\.invokeMethod\('getScanRootPath'\)\}"\);
    await channel\.invokeMethod\('setScanRoot', \{'path': '/Users/aryanraj/Downloads'\}\);
    print\("DEBUG TEST: new root = \$\{await channel\.invokeMethod\('getScanRootPath'\)\}"\);
  \} catch\(e\) \{
    print\("DEBUG TEST ERROR: \$e"\);
  \}"""

replacement = r"""void main() async {
  FlutterError.onError = (details) { print('FLUTTER ERROR: ${details.exceptionAsString()}'); };
  print('APP START: ensureInitialized');
  WidgetsFlutterBinding.ensureInitialized();"""

content = re.sub(target, replacement, content)

with open("lib/main.dart", "w") as f:
    f.write(content)
