import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target_listview = r"    return ListView\.builder\("
replacement_listview = r"    return Scrollbar(\n      interactive: true,\n      thickness: 6.0,\n      radius: const Radius.circular(10),\n      child: ListView.builder("
content = re.sub(target_listview, replacement_listview, content)

target_listview_end = r"""        return ItemCard\(
          item: item,
          inactivityThresholdDays: widget\.inactivityThresholdDays,
          selectionMode: widget\.selectionMode,
          selected: widget\.selectedIds\.contains\(item\.id\),
          onTap: \(\) \{
            if \(widget\.selectionMode\) \{
              widget\.onSelectionToggled\(item\.id\);
            \}
          \},
        \);
      \},
    \);
  \}"""

replacement_listview_end = r"""        return ItemCard(
          item: item,
          inactivityThresholdDays: widget.inactivityThresholdDays,
          selectionMode: widget.selectionMode,
          selected: widget.selectedIds.contains(item.id),
          onTap: () {
            if (widget.selectionMode) {
              widget.onSelectionToggled(item.id);
            }
          },
        );
      },
    ),
    );
  }"""
content = re.sub(target_listview_end, replacement_listview_end, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
