import 'package:flutter/material.dart';
import 'package:free_space/core/utils/file_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:free_space/data/repositories/settings_repository.dart';
import 'package:free_space/presentation/providers/items_provider.dart';
import 'package:free_space/presentation/providers/database_provider.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';
import 'package:free_space/presentation/providers/storage_provider.dart';
import 'package:free_space/presentation/widgets/item_card.dart';
import 'package:free_space/presentation/widgets/mode_toggle.dart';
import 'package:free_space/presentation/widgets/storage_chart.dart';
import 'package:free_space/core/theme/app_colors.dart';

/// The main dashboard screen showing storage usage and quick stats.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageInfoAsync = ref.watch(storageInfoProvider);
    final tempItemsAsync = ref.watch(temporaryItemsProvider);
    final tempCountAsync = ref.watch(temporaryCountProvider);
    final permCountAsync = ref.watch(permanentCountProvider);
    final binCountAsync = ref.watch(binnedCountProvider);
    final opMode = ref.watch(operationModeProvider);
    final inactivityDays = ref.watch(inactivityDaysProvider).valueOrNull ?? 30;

    return RefreshIndicator(
      onRefresh: () async {
        // In a real app, this would refresh the data
        ref.invalidate(storageInfoProvider);
        ref.invalidate(temporaryItemsProvider);
        ref.invalidate(permanentCountProvider);
        ref.invalidate(binnedCountProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 940),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STORAGE OVERVIEW',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.8,
                                  ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Your storage',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A clear view of what’s taking up space.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Storage Chart Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: storageInfoAsync.when(
                        data: (info) => StorageChart(storageInfo: info),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, stack) => Center(
                          child: Text('Error loading storage info: $err'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Temporary',
                          icon: Icons.timer,
                          count: tempCountAsync.valueOrNull ?? 0,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Permanent',
                          icon: Icons.lock,
                          count: permCountAsync.valueOrNull ?? 0,
                          color: AppColors.sage,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Bin',
                          icon: Icons.delete,
                          count: binCountAsync.valueOrNull ?? 0,
                          color: AppColors.rose,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mode Toggle Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Operation Mode',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  opMode.valueOrNull == OperationMode.autoBin
                                      ? Icons.auto_delete
                                      : Icons.preview,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  opMode.valueOrNull == OperationMode.autoBin
                                      ? 'Auto-Bin'
                                      : 'Hold & Review',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            opMode.valueOrNull == OperationMode.autoBin
                                ? 'Items unused past the threshold will be automatically moved to the bin.'
                                : 'Items unused past the threshold will be held for your review.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              context.go('/settings');
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.settings,
                                    size: 14,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Visit in app setting to change',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Total Space Saved
                  Consumer(
                    builder: (context, ref, child) {
                      final spaceSaved = ref.watch(totalSpaceSavedProvider).valueOrNull ?? 0;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Card(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.savings_rounded,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Space Freed',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        FileUtils.formatFileSize(spaceSaved),
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                              fontWeight: FontWeight.bold,
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
                    },
                  ),

                  // Recent Activity
                  Text(
                    'Recently active',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  tempItemsAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text('No recent items.'),
                            ),
                          ),
                        );
                      }
                      final recentItems = items.take(5).toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentItems.length,
                        itemBuilder: (context, index) {
                          return ItemCard(
                            item: recentItems[index],
                            inactivityThresholdDays: inactivityDays,
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Color color;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 6.0),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
