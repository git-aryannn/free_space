with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

import re

# Find "child: Text('Failed to load items:\n$err'),\n                ),"
# We want to replace everything after that up to "floatingActionButton: Column("

target_regex = r"child: Text\('Failed to load items:\\n\$err'\),\n                \),\n(?:[\s\S]*?)floatingActionButton: Column\("

replacement = r'''child: Text('Failed to load items:\n$err'),
                ),
              ),
            ),
      ),
      floatingActionButton: Column('''

content = re.sub(target_regex, replacement, content)

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
