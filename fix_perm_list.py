import re
with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target = r"""          onDoubleTap: \(\) => widget\.onReveal\(item\),
        \);
      \},
    \);
  \}
\}

class _FilterChipWidget extends ConsumerWidget \{"""

replacement = r"""          onDoubleTap: () => widget.onReveal(item),
        );
      },
    ),
    );
  }
}

class _FilterChipWidget extends ConsumerWidget {"""
content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
