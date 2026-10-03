import re

with open("lib/presentation/screens/home/dashboard_screen.dart", "r") as f:
    content = f.read()

target = r'''                          Row\(
                            children: \[
                              Icon\(
                                Icons.settings,
                                size: 14,
                                color: Theme.of\(context\).colorScheme.primary,
                              \),
                              const SizedBox\(width: 4\),
                              Text\(
                                'Visit in app setting to change',
                                style: Theme.of\(context\).textTheme.labelSmall\?.copyWith\(
                                      color: Theme.of\(context\).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    \),
                              \),
                            \],
                          \),'''

replacement = r'''                          InkWell(
                            onTap: () {
                              context.go('/settings');
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
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
                            ),
                          ),'''

content = re.sub(target, replacement, content, flags=re.DOTALL)

with open("lib/presentation/screens/home/dashboard_screen.dart", "w") as f:
    f.write(content)

