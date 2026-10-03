with open("lib/presentation/providers/settings_provider.dart", "a") as f:
    f.write("\n\nfinal detectionModeProvider = FutureProvider<DetectionMode>((ref) async {\n  return ref.watch(settingsRepositoryProvider).getDetectionMode();\n});\n")

with open("lib/data/repositories/item_repository.dart", "r") as f:
    item_repo = f.read()
if "getAllItems()" not in item_repo:
    item_repo = item_repo.replace(
        "class ItemRepository {",
        "class ItemRepository {\n  Future<List<TrackedItemModel>> getAllItems() async {\n    final rows = await _dao.select(_dao.trackedItems).get();\n    return rows.map((r) => TrackedItemModel.fromDbRow(r)).toList();\n  }\n"
    )
with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(item_repo)
