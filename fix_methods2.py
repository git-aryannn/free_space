import re

with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

target = r"""            await _showSystemTrashItemActions\(item\);
      \),
          \},
          onLongPress: \(\) => _toggleSystemTrashSelection\(item\),
        \),
    \);
  \}"""

replacement = r"""            await _showSystemTrashItemActions(item);
          },
          onLongPress: () => _toggleSystemTrashSelection(item),
        ),
      ),
    );
  }"""
content = re.sub(target, replacement, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
