import re

with open("lib/presentation/providers/inbox_provider.dart", "r") as f:
    content = f.read()

target = r'''class InboxNotifier extends StateNotifier<InboxState> \{
  InboxNotifier\(\) : super\(const InboxState\(\)\);

  void setItems\(List<TrackedItemModel> items\) \{
    state = InboxState\(pendingItems: items\);
  \}

  void addItems\(List<TrackedItemModel> items\) \{
    final existingPaths = state\.pendingItems\.map\(\(e\) => e\.path\)\.toSet\(\);
    final newItems = items\.where\(\(e\) => !existingPaths\.contains\(e\.path\)\)\.toList\(\);
    state = InboxState\(pendingItems: \[\.\.\.state\.pendingItems, \.\.\.newItems\]\);
  \}

  void removeItem\(String path\) \{
    final newItems = state\.pendingItems\.where\(\(p\) => p\.path != path\)\.toList\(\);
    state = InboxState\(pendingItems: newItems\);
  \}
\}

final inboxProvider = StateNotifierProvider<InboxNotifier, InboxState>\(\(ref\) \{
  return InboxNotifier\(\);
\}\);'''

replacement = r'''import 'package:free_space/data/repositories/settings_repository.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';

class InboxNotifier extends StateNotifier<InboxState> {
  final SettingsRepository settingsRepo;

  InboxNotifier(this.settingsRepo) : super(const InboxState()) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await settingsRepo.getInboxItems();
    if (items.isNotEmpty && mounted) {
      state = InboxState(pendingItems: items);
    }
  }

  void setItems(List<TrackedItemModel> items) {
    state = InboxState(pendingItems: items);
    settingsRepo.setInboxItems(items);
  }

  void addItems(List<TrackedItemModel> items) {
    final existingPaths = state.pendingItems.map((e) => e.path).toSet();
    final newItems = items.where((e) => !existingPaths.contains(e.path)).toList();
    final updatedList = [...state.pendingItems, ...newItems];
    state = InboxState(pendingItems: updatedList);
    settingsRepo.setInboxItems(updatedList);
  }

  void removeItem(String path) {
    final newItems = state.pendingItems.where((p) => p.path != path).toList();
    state = InboxState(pendingItems: newItems);
    settingsRepo.setInboxItems(newItems);
  }
}

final inboxProvider = StateNotifierProvider<InboxNotifier, InboxState>((ref) {
  return InboxNotifier(ref.read(settingsRepositoryProvider));
});'''

content = re.sub(target, replacement, content)

with open("lib/presentation/providers/inbox_provider.dart", "w") as f:
    f.write(content)
