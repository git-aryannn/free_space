import re
with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

target = r"""          Text\(
            'No space wasted here\.',
      \),
            style: Theme\.of\(context\)\.textTheme\.bodyMedium\?\.copyWith\(
                  color: Colors\.grey\.shade500,
                \),
          \),
        \],
    \);
  \}"""

replacement = r"""          Text(
            'No space wasted here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }"""
content = re.sub(target, replacement, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
