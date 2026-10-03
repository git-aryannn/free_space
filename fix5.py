with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

import re

target = r'''                  child: Text\('Failed to load items:\\n\$err'\),
                \),
              \),
            \),
        \),
      \),'''

replacement = r'''                  child: Text('Failed to load items:\n$err'),
                ),
              ),
            ),
      ),'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
