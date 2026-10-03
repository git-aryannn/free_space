import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target = r"""        paths = await nativeService.selectScanItems\(\);
        if \(paths != null && paths.isNotEmpty\) \{
          await nativeService.setScanRoot\(paths.first\);
        \}"""

replacement = r"""        paths = await nativeService.selectScanItems();
        if (paths != null && paths.isNotEmpty) {
          import 'dart:io';
          File('/tmp/freespace_dart_set_root.txt').writeAsStringSync(paths.first);
          await nativeService.setScanRoot(paths.first);
        }"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
