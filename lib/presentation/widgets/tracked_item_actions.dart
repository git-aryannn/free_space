import 'package:flutter/material.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/models/tracked_item_model.dart';

Future<void> showTrackedItemActions(
  BuildContext context, {
  required TrackedItemModel item,
  required Future<void> Function(ItemCategory category) onMove,
  required Future<void> Function() onDelete,
  required Future<void> Function() onReveal,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            title: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle:
                Text(item.path, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Open/View'),
            onTap: () => _runAction(context, sheetContext, onReveal),
          ),
          if (item.category != ItemCategory.temporary)
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Move to Temporary'),
              onTap: () => _runAction(
                context,
                sheetContext,
                () => onMove(ItemCategory.temporary),
              ),
            ),
          if (item.category != ItemCategory.permanent)
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Move to Permanent'),
              onTap: () => _runAction(
                context,
                sheetContext,
                () => onMove(ItemCategory.permanent),
              ),
            ),
          if (item.category != ItemCategory.binned)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Move to Bin'),
              onTap: () => _runAction(
                context,
                sheetContext,
                () => onMove(ItemCategory.binned),
              ),
            ),
          if (item.category == ItemCategory.binned)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete permanently'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete permanently?'),
                    content: Text('Delete "${item.name}" from the list?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await _runAction(context, null, onDelete);
                }
              },
            ),
        ],
      ),
    ),
  );
}

Future<void> _runAction(
  BuildContext notificationContext,
  BuildContext? sheetContext,
  Future<void> Function() action,
) async {
  if (sheetContext != null) Navigator.of(sheetContext).pop();
  try {
    await action();
  } catch (error) {
    if (notificationContext.mounted) {
      ScaffoldMessenger.of(notificationContext).showSnackBar(
        SnackBar(content: Text('Action failed: $error')),
      );
    }
  }
}
