import re

with open("lib/main.dart", "r") as f:
    content = f.read()

target = r"""  print\('APP START: initializeBackgroundService'\);
  await initializeBackgroundService\(\);
  print\('APP START: initializeWorkManager'\);
  await initializeWorkManager\(\);"""

replacement = r"""  import 'dart:io' show Platform;
  
  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
    try {
      print('APP START: initializeBackgroundService');
      await initializeBackgroundService();
    } catch (e) {
      print('Background service init failed: $e');
    }
    
    try {
      print('APP START: initializeWorkManager');
      await initializeWorkManager();
    } catch (e) {
      print('WorkManager init failed: $e');
    }
  }"""

content = re.sub(target, replacement, content)

with open("lib/main.dart", "w") as f:
    f.write(content)
