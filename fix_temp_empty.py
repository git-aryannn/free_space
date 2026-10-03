import re

with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

target = r"""          \],
        \),
    \);
  \}
\}"""

replacement = r"""          ],
        ),
      ),
    );
  }
}"""
content = re.sub(target, replacement, content)

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
