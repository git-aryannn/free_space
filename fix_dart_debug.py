import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target = r"""          import 'dart:io';
          File\('/tmp/freespace_dart_set_root.txt'\).writeAsStringSync\(paths.first\);"""

replacement = r"""          // File writes
          try {
            final f = await ref.read(nativePlatformServiceProvider).getDownloadsPath();
          } catch(e) {}"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
