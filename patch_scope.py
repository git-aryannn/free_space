import re

with open("lib/presentation/screens/home/home_shell.dart", "r") as f:
    content = f.read()

target = r'''      child: widget\.navigationShell,
    \);
  \}
\}'''

replacement = '''      child: widget.navigationShell,
    ),
    );
  }
}'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/home/home_shell.dart", "w") as f:
    f.write(content)

