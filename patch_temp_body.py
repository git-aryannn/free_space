import re

with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

target = r"""                \.\.sort\(\(a, b\) \{
                  switch \(currentSort\) \{
                    case ItemSort\.daysUnused:
                      return b\.daysUnused\.compareTo\(a\.daysUnused\);"""

replacement = r"""                ..sort((a, b) {
                  switch (currentSort) {
                    case ItemSort.daysUnused:
                      return a.daysUntilBinned(inactivityDays).compareTo(b.daysUntilBinned(inactivityDays));"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
