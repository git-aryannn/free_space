import 'package:flutter/material.dart';
import 'package:free_space/core/theme/app_colors.dart';
import 'package:free_space/data/models/item_enums.dart';

/// Displays a dialog/bottom sheet for the user to categorize an item.
Future<ItemCategory?> showCategoryDialog(
    BuildContext context, String itemName) {
  return showModalBottomSheet<ItemCategory>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Categorize "$itemName"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context,
              category: ItemCategory.permanent,
              icon: Icons.lock_outline,
              title: 'Permanent',
              description: 'This item will never be auto-deleted.',
              color: AppColors.gold,
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              category: ItemCategory.temporary,
              icon: Icons.timer_outlined,
              title: 'Temporary',
              description: 'Subject to the 30-day inactivity rule.',
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildOptionCard(
  BuildContext context, {
  required ItemCategory category,
  required IconData icon,
  required String title,
  required String description,
  required Color color,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Theme.of(context).dividerColor),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.of(context).pop(category),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
