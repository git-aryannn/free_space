import re

with open("lib/presentation/screens/home/dashboard_screen.dart", "r") as f:
    content = f.read()

target = r'''                  // Mode Toggle Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                        ],
                      ),
                    ),
                  ),'''

replacement = r'''                  // Mode Toggle Section
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  opMode.valueOrNull == OperationMode.autoBin 
                                      ? Icons.auto_delete 
                                      : Icons.preview,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  opMode.valueOrNull == OperationMode.autoBin 
                                      ? 'Auto-Bin' 
                                      : 'Hold & Review',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.settings,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Visit in app setting to change',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),'''

content = content.replace(target, replacement)

with open("lib/presentation/screens/home/dashboard_screen.dart", "w") as f:
    f.write(content)
