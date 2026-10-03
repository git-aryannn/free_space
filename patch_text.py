import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = r'''                    Text\(
                      'If an item remains unused for this many continuous days, it will be moved to the bin if Auto-Bin mode is chosen\. Items in the bin will be permanently deleted after 30 days automatically \(this is fixed and cannot be changed\)\.',
                      style: theme\.textTheme\.bodySmall\?\.copyWith\(
                        color: colorScheme\.onSurfaceVariant,
                      \),
                    \),'''

replacement = '''                    Text(
                      'Hold & Review Mode:\\n'
                      'Items unused for this threshold will move from Permanent to Temporary.\\n\\n'
                      'Auto-Bin Mode:\\n'
                      'Items unused for this threshold will move from Permanent to Temporary, and if they remain unused in Temporary for another threshold duration, they automatically move to Bin.\\n\\n'
                      '• Any view/open resets the countdown.\\n'
                      '• Items in the Bin are permanently deleted after 30 days (this is fixed and cannot be changed).',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)

