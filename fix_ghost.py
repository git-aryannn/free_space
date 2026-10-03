import re

with open("lib/presentation/widgets/item_action_helpers.dart", "r") as f:
    content = f.read()

if "import 'dart:io';" not in content:
    content = "import 'dart:io';\n" + content

target = r'''  if \(category == ItemCategory\.binned && item\.category != ItemCategory\.binned\) \{
    final moved = await nativeService\.moveItemsToSystemTrash\(\[item\.path\]\);
    if \(!moved\.containsKey\(item\.path\)\) \{
      throw StateError\('The system did not move this item to its Trash\.'\);
    \}
    await repository\.moveItemsToBin\(\{item\.id: moved\[item\.path\]\}\);
  \}'''

replacement = r'''  if (category == ItemCategory.binned && item.category != ItemCategory.binned) {
    if (item.path.contains('Free Space Bin') || !File(item.path).existsSync()) {
      // File is already deleted or already in the app's bin. Just update DB.
      await repository.moveItemsToBin({item.id: item.path});
    } else {
      final moved = await nativeService.moveItemsToSystemTrash([item.path]);
      if (!moved.containsKey(item.path)) {
        throw StateError('The system did not move this item to its Trash. (File might be missing or permission denied)');
      }
      await repository.moveItemsToBin({item.id: moved[item.path]});
    }
  }'''

content = re.sub(target, replacement, content)

# Also fix moveTrackedItems (plural)
target2 = r'''  if \(category == ItemCategory\.binned\) \{
    final moved = await nativeService\.moveItemsToSystemTrash\(
      items\.map\(\(item\) => item\.path\)\.toList\(\),
    \);
    final movedIds = <int, String\?>\{
      for \(final item in items\)
        if \(moved\.containsKey\(item\.path\)\) item\.id: moved\[item\.path\],
    \};'''

replacement2 = r'''  if (category == ItemCategory.binned) {
    final existingPaths = items.where((i) => File(i.path).existsSync() && !i.path.contains('Free Space Bin')).map((i) => i.path).toList();
    final moved = existingPaths.isEmpty ? <String?, String?>{} : await nativeService.moveItemsToSystemTrash(existingPaths);
    
    final movedIds = <int, String?>{};
    for (final item in items) {
      if (!File(item.path).existsSync() || item.path.contains('Free Space Bin')) {
        movedIds[item.id] = item.path;
      } else if (moved.containsKey(item.path)) {
        movedIds[item.id] = moved[item.path];
      }
    }'''

content = re.sub(target2, replacement2, content)

with open("lib/presentation/widgets/item_action_helpers.dart", "w") as f:
    f.write(content)
