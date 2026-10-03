import re

with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

# I will replace:
#           ],
#         ),
#     );
#   }
# With:
#           ],
#         ),
#       ),
#     );
#   }

content = re.sub(r"          \],\n        \),\n    \);\n  \}", r"          ],\n        ),\n      ),\n    );\n  }", content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
