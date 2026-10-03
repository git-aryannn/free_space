import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target = r'''        if \(scanTarget == _ScanTarget\.fullDevice\) \{
          final rootPath = '/storage/emulated/0';
          await nativeService\.setScanRoot\(rootPath\);
          paths = \[rootPath\];'''

replacement = '''        if (scanTarget == _ScanTarget.fullDevice) {
          final rootPath = await nativeService.getExternalStorageRootPath();
          await nativeService.setScanRoot(rootPath);
          paths = [rootPath];'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)

