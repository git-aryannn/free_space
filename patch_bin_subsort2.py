import re

with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

target = r"""            items\.sort\(\(a, b\) \{
              final cmp = \(a\.trashedAt \?\? a\.startDay\)\.compareTo\(b\.trashedAt \?\? b\.startDay\);
              return cmp != 0 \? cmp : b\.sizeBytes\.compareTo\(a\.sizeBytes\);
            \}\);"""

replacement = r"""            items.sort((a, b) {
              final aDate = a.binnedAt ?? a.temporarySince ?? a.createdAt;
              final bDate = b.binnedAt ?? b.temporarySince ?? b.createdAt;
              final cmp = aDate.compareTo(bDate);
              return cmp != 0 ? cmp : b.sizeBytes.compareTo(a.sizeBytes);
            });"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
