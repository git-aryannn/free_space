import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inbox_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:free_space/core/theme/app_colors.dart';

/// An adaptive scaffold that provides a BottomNavigationBar for mobile
/// and a NavigationRail for desktop/tablet.
class AdaptiveScaffold extends StatelessWidget {
  /// The current index of the selected destination.
  final int currentIndex;

  /// Callback when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// The body content for the scaffold.
  final Widget child;

  /// The list of navigation destinations.
  final List<NavigationDestination> destinations;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile Layout
          return Scaffold(
            appBar: _buildAppBar(context),
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            ),
          );
        } else {
          // Desktop/Tablet Layout
          return Scaffold(
            appBar: _buildAppBar(context),
            body: Row(
              children: [
                NavigationRail(
                  minWidth: 80,
                  minExtendedWidth: 224,
                  groupAlignment: -0.7,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: constraints.maxWidth >= 800
                      ? null
                      : NavigationRailLabelType.all,
                  extended: constraints.maxWidth >= 800,
                  leading: constraints.maxWidth >= 800
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Free Space',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                  destinations: destinations.map((dest) {
                    return NavigationRailDestination(
                      icon: dest.icon,
                      selectedIcon: dest.selectedIcon,
                      label: Text(dest.label),
                    );
                  }).toList(),
                ),
                VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(child: child),
              ],
            ),
          );
        }
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 34,
              height: 34,
            ),
          ),
          const SizedBox(width: 11),
          const Text('Free Space'),
        ],
      ),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final inboxCount = ref.watch(inboxProvider).pendingItems.length;
            return IconButton(
              tooltip: 'Inbox',
              icon: Badge(
                isLabelVisible: inboxCount > 0,
                backgroundColor: AppColors.gold,
                textColor: Colors.black,
                label: Text(inboxCount.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                child: const Icon(Icons.inbox_outlined),
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              onPressed: () {
                context.push('/inbox');
              },
            );
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          onPressed: () {
            context.push('/settings');
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
