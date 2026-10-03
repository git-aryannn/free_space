import re
with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

target = r"""                        \.\.\.systemItems\.map\(_buildSystemTrashCard\),
                      \],
                    \],
                  \),
                \),
              \),
            \],
          \);
        \},"""

replacement = r"""                        ...systemItems.map(_buildSystemTrashCard),
                      ],
                    ],
                  ),
                ),
              ),
              ),
            ],
          );
        },"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
