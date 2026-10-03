import re
with open("lib/presentation/screens/inbox/inbox_screen.dart", "r") as f:
    content = f.read()

target = r"""          \? const Center\(child: Text\('No items in inbox'\)\)
          : ListView\.builder\("""

replacement = r"""          ? const Center(child: Text('No items in inbox'))
          : Scrollbar(
              interactive: true,
              thickness: 6.0,
              radius: const Radius.circular(10),
              child: ListView.builder("""
content = re.sub(target, replacement, content)

target_end = r"""                \),
              \);
            \},
          \),
    \);
  \}
\}"""

replacement_end = r"""                ),
              );
            },
          ),
          ),
    );
  }
}"""
content = re.sub(target_end, replacement_end, content)

with open("lib/presentation/screens/inbox/inbox_screen.dart", "w") as f:
    f.write(content)
