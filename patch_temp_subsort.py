import re

with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

target = r"""                    case ItemSort\.daysUnused:
                      return a\.daysUntilBinned\(inactivityDays\)\.compareTo\(b\.daysUntilBinned\(inactivityDays\)\);"""

replacement = r"""                    case ItemSort.daysUnused:
                      final cmp = a.daysUntilBinned(inactivityDays).compareTo(b.daysUntilBinned(inactivityDays));
                      return cmp != 0 ? cmp : b.sizeBytes.compareTo(a.sizeBytes);"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
