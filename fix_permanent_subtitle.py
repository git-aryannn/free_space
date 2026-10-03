import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target = r'''            if \(selectedFolderPath.valueOrNull case final path\?\)
              Text\(
                path,
                maxLines: 1,
                overflow: TextOverflow\.ellipsis,
                style: Theme\.of\(context\)\.textTheme\.labelSmall\?\.copyWith\(
                      color: Theme\.of\(context\)\.colorScheme\.onSurfaceVariant,
                    \),
              \),'''

replacement = r'''            Text(
              selectedFolderPath.valueOrNull ?? 'Internal Storage (Full Device Access)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)

