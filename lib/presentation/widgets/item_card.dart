import 'package:flutter/material.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/core/utils/file_utils.dart';
import 'package:free_space/core/theme/app_colors.dart';
import 'package:free_space/core/constants/app_constants.dart';

/// A card displaying information about a specific tracked item.
class ItemCard extends StatelessWidget {
  /// The item model.
  final TrackedItemModel item;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Double tap callback.
  final VoidCallback? onDoubleTap;

  /// Long press callback.
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool selected;
  final int inactivityThresholdDays;

  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
    this.inactivityThresholdDays = AppConstants.defaultInactivityDays,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        child: Column(
          children: [
            if (item.isFlagged)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                color: AppColors.rose.withValues(alpha: 0.12),
                child: const Text(
                  'Ready to Bin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.rose,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: selectionMode
                    ? Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      )
                    : Icon(
                        FileUtils.getIconForItem(
                          type: item.type,
                          name: item.name,
                          mimeType: item.mimeType,
                        ),
                        color: colorScheme.onPrimaryContainer,
                      ),
              ),
              title: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${FileUtils.formatFileSize(item.sizeBytes)} • ${item.type.name}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _lastAccessLabel(item.daysUnused),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.category == ItemCategory.temporary) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.auto_delete_outlined,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _temporaryCountdownLabel(
                                item.daysUntilBinned(inactivityThresholdDays),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              trailing: _buildTrailingWidget(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingWidget(BuildContext context) {
    switch (item.category) {
      case ItemCategory.temporary:
        final daysLeft = item.daysUntilBinned(inactivityThresholdDays);
        Color chipColor = AppColors.sage;
        if (daysLeft <= 3) {
          chipColor = AppColors.rose;
        } else if (daysLeft <= 7) {
          chipColor = AppColors.gold;
        }

        return Tooltip(
          message: _temporaryCountdownLabel(daysLeft),
          child: Chip(
            label: Text(
              '$daysLeft d left',
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
            backgroundColor: chipColor,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            visualDensity: VisualDensity.compact,
          ),
        );
      case ItemCategory.permanent:
        return const Icon(Icons.lock_outline, color: AppColors.gold);
      case ItemCategory.binned:
        final daysLeft =
            item.daysUntilPermanentDeletion(AppConstants.binRetentionDays);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Tooltip(
              message: daysLeft == 0
                  ? 'Expired; waiting for permanent deletion'
                  : '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} until permanent deletion',
              child: Text(
                daysLeft == 0 ? 'Delete due' : '$daysLeft d left',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: daysLeft <= 3
                      ? AppColors.rose
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restore, size: 20, color: AppColors.sage),
                SizedBox(width: 8),
                Icon(
                  Icons.delete_forever,
                  size: 20,
                  color: AppColors.rose,
                ),
              ],
            ),
          ],
        );
    }
  }

  String _lastAccessLabel(int days) {
    if (days == 0) return 'Accessed today';
    if (days == 1) return 'Not accessed for 1 day';
    return 'Not accessed for $days days';
  }

  String _temporaryCountdownLabel(int daysLeft) {
    final days = '$daysLeft ${daysLeft == 1 ? 'day' : 'days'}';
    return '$days left to move into Bin automatically';
  }
}
