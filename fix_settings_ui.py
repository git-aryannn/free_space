import re
with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = r"""            const SizedBox\(height: 16\),
            _buildActionCard\(
              context,
              title: 'Empty App Data',"""

replacement = r"""            const SizedBox(height: 16),
            _buildIgnoredFoldersSection(context, ref, db),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: 'Empty App Data',"""
content = re.sub(target, replacement, content)

# Now inject _buildIgnoredFoldersSection
target2 = r"""  Widget _buildActionCard\("""
replacement2 = r"""  Widget _buildIgnoredFoldersSection(BuildContext context, WidgetRef ref, AppDatabase db) {
    return FutureBuilder<List<String>>(
      future: db.appSettingsDao.getIgnoredPaths(),
      builder: (context, snapshot) {
        final paths = snapshot.data ?? [];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: ExpansionTile(
            title: const Text('Ignored Folders & Paths'),
            subtitle: Text('${paths.length} items ignored from scanning'),
            leading: const Icon(Icons.folder_off_outlined),
            shape: const Border(),
            children: [
              if (paths.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No ignored folders. Free Space will scan all allowed directories.'),
                ),
              ...paths.map((path) => ListTile(
                title: Text(path, style: const TextStyle(fontSize: 13)),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () async {
                    await db.appSettingsDao.removeIgnoredPath(path);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Path removed. It will be scanned next time.')),
                      );
                      // Force a rebuild to reflect the removed path
                      // In a real app we might use a Riverpod provider for ignored paths
                      // Here we just trigger a rebuild by toggling theme or something,
                      // or since it's a settings screen, just popping and re-entering is fine.
                      (context as Element).markNeedsBuild();
                    }
                  },
                ),
              )),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    final ctrl = TextEditingController();
                    final path = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Ignore Path'),
                        content: TextField(
                          controller: ctrl,
                          decoration: const InputDecoration(
                            hintText: 'e.g., WhatsApp Images, /Download/Secret',
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Add')),
                        ],
                      )
                    );
                    if (path != null && path.isNotEmpty) {
                      await db.appSettingsDao.addIgnoredPath(path);
                      if (context.mounted) {
                        (context as Element).markNeedsBuild();
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Path or Keyword'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCard("""
content = re.sub(target2, replacement2, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
