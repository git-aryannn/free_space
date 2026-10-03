with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

import re

# We will match from const SizedBox(height: 12), to Text( 'Hold & Review Mode: ... ),
# and replace it with a single triple-quoted Dart string.

# Just replace all that broken string block
start_idx = content.find("const SizedBox(height: 12),")
end_idx = content.find("style: theme.textTheme.bodySmall?.copyWith(")

if start_idx != -1 and end_idx != -1:
    before = content[:start_idx]
    after = content[end_idx:]
    
    replacement = """const SizedBox(height: 12),
                    Text(
                      '''Hold & Review Mode:
Items unused for this threshold will move from Permanent to Temporary.

Auto-Bin Mode:
Items unused for this threshold will move from Permanent to Temporary, and if they remain unused in Temporary for another threshold duration, they automatically move to Bin.

• Any view/open resets the countdown.
• Items in the Bin are permanently deleted after 30 days (this is fixed and cannot be changed).''',
                      """
    content = before + replacement + after
    with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
        f.write(content)

