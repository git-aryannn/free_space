import re

with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

content = content.replace("        key: _nestedScrollViewKey,\n", "")

target_fab = r"""      floatingActionButton: Column\(
        mainAxisSize: MainAxisSize\.min,
        children: \[
          FloatingActionButton\(
            heroTag: 'bin_select',
            onPressed: \(\) => setState\(\(\) \{
              _selectionMode = !_selectionMode;
              _selectedIds\.clear\(\);
              _selectedSystemTrashPaths\.clear\(\);
            \}\),
            tooltip: _selectionMode \? 'Exit selection' : 'Select items',
            child: Icon\(_selectionMode \? Icons\.close : Icons\.checklist\),
          \),
        \],
      \),"""

replacement_fab = r"""      floatingActionButton: FloatingActionButton(
        heroTag: 'bin_select',
        onPressed: () => setState(() {
          _selectionMode = !_selectionMode;
          _selectedIds.clear();
          _selectedSystemTrashPaths.clear();
        }),
        tooltip: _selectionMode ? 'Exit selection' : 'Select items',
        child: Icon(_selectionMode ? Icons.close : Icons.checklist),
      ),"""

content = re.sub(target_fab, replacement_fab, content)

target_listview = r"                  child: ListView\("
replacement_listview = r"                  child: Scrollbar(\n                    interactive: true,\n                    thickness: 6.0,\n                    radius: const Radius.circular(10),\n                    child: ListView("
content = re.sub(target_listview, replacement_listview, content)

target_listview_end = r"""                      \],
                    \),
                  \),
                \),
              \],
            \);
          \},
          loading: \(\) => const Center\(child: CircularProgressIndicator\(\)\),
          error: \(err, stack\) => Center\(child: Text\('Error: \$err'\)\),
        \),
      \),
    \);
  \}"""

replacement_listview_end = r"""                      ],
                    ),
                  ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }"""
content = re.sub(target_listview_end, replacement_listview_end, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
