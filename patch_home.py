import re

with open("lib/presentation/screens/home/home_shell.dart", "r") as f:
    content = f.read()

target = r'''  Future<void> _handleNewFileDetected\(Map<String, dynamic> data\) async \{
    final path = data\['path'\] as String\?;
    final name = data\['name'\] as String\?;
    final sizeBytes = \(data\['sizeBytes'\] as num\?\)\?\.toInt\(\) \?\? 0;
    if \(path == null \|\| name == null\) return;
    
    if \(!mounted\) return;
    final result = await showDialog<ItemCategory>\(
      context: context,
      barrierDismissible: false,
      builder: \(context\) => AlertDialog\(
        title: const Text\('New Item Detected'\),
        content: Text\('How would you like to store "\$name"\?'\),
        actions: \[
          TextButton\(
            onPressed: \(\) => Navigator\.pop\(context, ItemCategory\.temporary\),
            child: const Text\('Temporary'\),
          \),
          FilledButton\(
            onPressed: \(\) => Navigator\.pop\(context, ItemCategory\.permanent\),
            child: const Text\('Permanent'\),
          \),
        \],
      \),
    \);'''

replacement = '''  Future<void> _handleNewFileDetected(Map<String, dynamic> data) async {
    final path = data['path'] as String?;
    final name = data['name'] as String?;
    final sizeBytes = (data['sizeBytes'] as num?)?.toInt() ?? 0;
    if (path == null || name == null) return;
    
    // Show notification for background handling
    await ref.read(notificationServiceProvider).showNewItemNotification(name, path, sizeBytes);
    
    if (!mounted) return;
    final result = await showDialog<ItemCategory>(
      context: context,
      barrierDismissible: false,
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
    
    if (result != null) {
      await ref.read(itemRepositoryProvider).trackNewFile(path, result, name);
      // Cancel the notification since we handled it in the app
      await ref.read(notificationServiceProvider).cancelNotification(path.hashCode);
    }'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/home/home_shell.dart", "w") as f:
    f.write(content)

