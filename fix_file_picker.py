import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = r"""                  onPressed: \(\) async \{
                    // Just a dummy add for now, real app might use file picker
                    final controller = TextEditingController\(\);
                    final path = await showDialog<String>\(
                      context: context,
                      builder: \(ctx\) => AlertDialog\(
                        title: const Text\('Add Ignored Path'\),
                        content: TextField\(
                          controller: controller,
                          decoration: const InputDecoration\(
                              hintText: '/storage/emulated/0/Download/Secret'\),
                        \),
                        actions: \[
                          TextButton\(
                              onPressed: \(\) => Navigator\.pop\(ctx\),
                              child: const Text\('Cancel'\)\),
                          FilledButton\(
                              onPressed: \(\) =>
                                  Navigator\.pop\(ctx, controller\.text\),
                              child: const Text\('Add'\)\),
                        \],
                      \),
                    \);
                    if \(path != null && path\.isNotEmpty\) \{
                      ref\.read\(appSettingsDaoProvider\)\.addIgnoredPath\(path\);
                    \}
                  \},"""

replacement = r"""                  onPressed: () async {
                    try {
                      final path = await FilePicker.platform.getDirectoryPath(
                        dialogTitle: 'Select Folder to Ignore',
                      );
                      if (path != null && path.isNotEmpty) {
                        ref.read(appSettingsDaoProvider).addIgnoredPath(path);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to pick folder: $e')),
                        );
                      }
                    }
                  },"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
