import re

with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

target = r"""            items\.sort\(\(a, b\) => \(a\.trashedAt \?\? a\.startDay\)\.compareTo\(b\.trashedAt \?\? b\.startDay\)\);"""

replacement = r"""            items.sort((a, b) {
              final cmp = (a.trashedAt ?? a.startDay).compareTo(b.trashedAt ?? b.startDay);
              return cmp != 0 ? cmp : b.sizeBytes.compareTo(a.sizeBytes);
            });"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
