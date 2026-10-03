import re

with open("lib/main.dart", "r") as f:
    content = f.read()

target = r"""void main\(\) async \{
  WidgetsFlutterBinding\.ensureInitialized\(\);"""

replacement = r"""import 'package:flutter/services.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    const channel = MethodChannel('com.freespace.native');
    print("DEBUG TEST: old root = ${await channel.invokeMethod('getScanRootPath')}");
    await channel.invokeMethod('setScanRoot', {'path': '/Users/aryanraj/Downloads'});
    print("DEBUG TEST: new root = ${await channel.invokeMethod('getScanRootPath')}");
  } catch(e) {
    print("DEBUG TEST ERROR: $e");
  }
"""

content = re.sub(target, replacement, content)

with open("lib/main.dart", "w") as f:
    f.write(content)
