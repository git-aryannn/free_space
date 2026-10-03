import re

with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

content = content.replace("        key: _nestedScrollViewKey,\n", "")

target_fab = r"""      floatingActionButton: Column\(
        mainAxisSize: MainAxisSize\.min,
        children: \[
          FloatingActionButton\(
            heroTag: 'temp_select',
            onPressed: \(\) => setState\(\(\) \{
              _selectionMode = !_selectionMode;
              _selectedIds\.clear\(\);
            \}\),
            tooltip: _selectionMode \? 'Exit selection' : 'Select items',
            child: Icon\(_selectionMode \? Icons\.close : Icons\.checklist\),
          \),
        \],
    \);"""

replacement_fab = r"""      floatingActionButton: FloatingActionButton(
        heroTag: 'temp_select',
        onPressed: () => setState(() {
          _selectionMode = !_selectionMode;
          _selectedIds.clear();
        }),
        tooltip: _selectionMode ? 'Exit selection' : 'Select items',
        child: Icon(_selectionMode ? Icons.close : Icons.checklist),
      ),
    );"""

content = re.sub(target_fab, replacement_fab, content)

target_listview = r"              return ListView\.builder\("
replacement_listview = r"              return Scrollbar(\n                interactive: true,\n                thickness: 6.0,\n                radius: const Radius.circular(10),\n                child: ListView.builder("
content = re.sub(target_listview, replacement_listview, content)

target_listview_end = r"""                \},
              \);"""
replacement_listview_end = r"""                },
              ),
              );"""
content = re.sub(target_listview_end, replacement_listview_end, content)

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
