import re

with open("lib/presentation/providers/inbox_provider.dart", "r") as f:
    content = f.read()

target = r'''  void setItems\(List<TrackedItem> items\) \{
    state = InboxState\(pendingItems: items\);
  \}'''

replacement = r'''  void setItems(List<TrackedItem> items) {
    state = InboxState(pendingItems: items);
  }

  void addItems(List<TrackedItem> items) {
    final existingPaths = state.pendingItems.map((e) => e.path).toSet();
    final newItems = items.where((e) => !existingPaths.contains(e.path)).toList();
    state = InboxState(pendingItems: [...state.pendingItems, ...newItems]);
  }'''

content = re.sub(target, replacement, content)

with open("lib/presentation/providers/inbox_provider.dart", "w") as f:
    f.write(content)

