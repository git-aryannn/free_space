import 'package:free_space/presentation/providers/storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/presentation/providers/inbox_provider.dart';
import 'package:free_space/presentation/providers/items_provider.dart';
import 'package:free_space/data/services/native_platform_service.dart';
import 'package:path/path.dart' as p;
import 'package:free_space/core/utils/file_utils.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  Set<String> selectedPaths = {};

  void _handleAction(
      List<TrackedItemModel> items, ItemCategory category) async {
    final itemRepo = ref.read(itemRepositoryProvider);
    final inboxNotifier = ref.read(inboxProvider.notifier);

    for (final item in items) {
      final newItem = item.copyWith(category: category);
      await itemRepo.addItem(newItem);
      inboxNotifier.removeItem(item.path);
    }

    // Refresh providers
    if (category == ItemCategory.temporary) {
      ref.invalidate(temporaryItemsProvider);
    } else {
      ref.invalidate(permanentItemsRevisionProvider);
    }

    selectedPaths.clear();
    if (mounted) setState(() {});
  }

  void _openItem(String path) {
    ref.read(nativePlatformServiceProvider).showInFileManager(path);
  }

  @override
  Widget build(BuildContext context) {
    final inboxState = ref.watch(inboxProvider);
    final theme = Theme.of(context);

    final items = inboxState.pendingItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Files'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  if (selectedPaths.length == items.length) {
                    selectedPaths.clear();
                  } else {
                    selectedPaths.addAll(items.map((e) => e.path));
                  }
                });
              },
              child: Text(selectedPaths.length == items.length
                  ? 'Deselect All'
                  : 'Select All'),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('You are all caught up!',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('No new files detected.',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedPaths.contains(item.path);

                return ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedPaths.add(item.path);
                        } else {
                          selectedPaths.remove(item.path);
                        }
                      });
                    },
                  ),
                  title: Text(item.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${FileUtils.formatFileSize(item.sizeBytes)} • ${p.dirname(item.path).split('/').last}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () => _openItem(item.path),
                  ),
                  onTap: () => _openItem(item.path),
                );
              },
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.timer_outlined),
                        label: const Text('Temporary'),
                        onPressed: selectedPaths.isEmpty
                            ? null
                            : () {
                                final selectedItems = items
                                    .where(
                                        (e) => selectedPaths.contains(e.path))
                                    .toList();
                                _handleAction(
                                    selectedItems, ItemCategory.temporary);
                              },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('Permanent'),
                        onPressed: selectedPaths.isEmpty
                            ? null
                            : () {
                                final selectedItems = items
                                    .where(
                                        (e) => selectedPaths.contains(e.path))
                                    .toList();
                                _handleAction(
                                    selectedItems, ItemCategory.permanent);
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
