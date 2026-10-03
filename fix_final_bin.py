import re
with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

target = r"""        error: \(err, stack\) => Center\(child: Text\('Error: \$err'\)\),
      \),
    \);
  \}

  Widget _buildTrackedItem\(TrackedItemModel item\) \{"""

replacement = r"""        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      ),
    );
  }

  Widget _buildTrackedItem(TrackedItemModel item) {"""
content = re.sub(target, replacement, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
