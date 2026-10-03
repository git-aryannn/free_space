import re

with open("lib/presentation/screens/home/dashboard_screen.dart", "r") as f:
    content = f.read()

# First replace the StatCard class to make space for space saved card
target = r"""                  // Recent Activity"""

replacement = r"""                  // Total Space Saved
                  Consumer(
                    builder: (context, ref, child) {
                      final spaceSaved = ref.watch(totalSpaceSavedProvider).valueOrNull ?? 0;
                      if (spaceSaved <= 0) return const SizedBox.shrink();
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
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.1),
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
                                        formatFileSize(spaceSaved),
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

                  // Recent Activity"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/home/dashboard_screen.dart", "w") as f:
    f.write(content)
