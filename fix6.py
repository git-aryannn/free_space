with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

import re

# Fix string literal
content = content.replace("child: Text('Failed to load items:\n$err')", "child: Text('Failed to load items:\\n$err')")

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
