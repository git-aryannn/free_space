import re
with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

target = r"""              \} finally \{
                ref
                  \.\.invalidate\(binnedItemsProvider\)
                  \.\.invalidate\(systemTrashItemsProvider\)
                  \.\.invalidate\(binnedCountProvider\);
      \),
              \}
              if \(dialogContext\.mounted\) Navigator\.pop\(dialogContext\);
            \},
            child: const Text\('Empty'\),
          \),
        \],
    \);
  \}"""

replacement = r"""              } finally {
                ref
                  ..invalidate(binnedItemsProvider)
                  ..invalidate(systemTrashItemsProvider)
                  ..invalidate(binnedCountProvider);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Empty'),
          ),
        ],
      ),
    );
  }"""
content = re.sub(target, replacement, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
