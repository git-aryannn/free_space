with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

import re

# The text to replace is around line 331. Let's find it using regex:
target = r'''                    const SizedBox\(height: 12\),
                    Text\(
                      'Hold & Review Mode:\n'
                      'Items unused for this threshold will move from Permanent to Temporary\.\n\n'
                      'Auto-Bin Mode:\n'
                      'Items unused for this threshold will move from Permanent to Temporary, and if they remain unused in Temporary for another threshold duration, they automatically move to Bin\.\n\n'
                      '• Any view/open resets the countdown\.\n'
                      '• Items in the Bin are permanently deleted after 30 days \(this is fixed and cannot be changed\)\.',
                      style: theme\.textTheme\.bodySmall\?\.copyWith\('''

replacement = '''                    const SizedBox(height: 12),
                    Text(
                      \'\'\'Hold & Review Mode:
Items unused for this threshold will move from Permanent to Temporary.

Auto-Bin Mode:
Items unused for this threshold will move from Permanent to Temporary, and if they remain unused in Temporary for another threshold duration, they automatically move to Bin.

• Any view/open resets the countdown.
• Items in the Bin are permanently deleted after 30 days (this is fixed and cannot be changed).\'\'\',
                      style: theme.textTheme.bodySmall?.copyWith('''

# There are multiple "const SizedBox(height: 12)," so we need to be careful!
# I messed it up with patch_settings_text2.py, wait!
