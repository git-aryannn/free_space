import re

with open("lib/presentation/screens/home/home_shell.dart", "r") as f:
    content = f.read()

init_state = r'''  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _purgeExpiredItems());
    _scheduleNextInactivityCheck();
  }'''

new_init_state = r'''  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _purgeExpiredItems());
    _scheduleNextInactivityCheck();
    _setupFileObserver();
  }

  void _setupFileObserver() {
    final nativeService = ref.read(nativePlatformServiceProvider);
    nativeService.setOnNewFileDetected((data) {
      _handleNewFileDetected(data);
    });
  }

  Future<void> _handleNewFileDetected(Map<String, dynamic> data) async {
    final path = data['path'] as String?;
    final name = data['name'] as String?;
    final sizeBytes = data['sizeBytes'] as int? ?? 0;
    if (path == null || name == null) return;
    
    if (!mounted) return;
    final result = await showDialog<ItemCategory>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Item Detected'),
        content: Text('How would you like to store "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ItemCategory.temporary),
            child: const Text('Temporary'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ItemCategory.permanent),
            child: const Text('Permanent'),
          ),
        ],
      ),
    );
    
    if (result != null && mounted) {
      import 'package:free_space/data/models/item_enums.dart';
      import 'package:free_space/data/models/tracked_item_model.dart';
      
      final item = TrackedItemModel(
        id: 0,
        name: name,
        path: path,
        type: ItemType.file,
        sizeBytes: sizeBytes,
        category: result,
        createdAt: DateTime.now(),
        lastUsedAt: DateTime.now(),
        isFlagged: false,
      );
      try {
        await ref.read(itemRepositoryProvider).addItem(item);
        if (result == ItemCategory.temporary) {
          ref.invalidate(temporaryItemsProvider);
          ref.invalidate(temporaryCountProvider);
        } else {
          ref.invalidate(permanentCountProvider);
          ref.read(permanentItemsRevisionProvider.notifier).state++;
        }
      } catch (e) {
        developer.log('Failed to add new detected item', error: e);
      }
    }
  }'''

# wait, adding imports inline inside the function won't work in Dart.
# Let's just do it cleanly via replace_file_content.
