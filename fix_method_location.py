import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

# First, extract the method from wherever it is.
# The method starts at "  Widget _buildIgnoredFoldersSection("
# and ends at the NEXT "  Widget " or the end of file (except for trailing braces)
match = re.search(r'  Widget _buildIgnoredFoldersSection\(.*?^  \}', content, re.MULTILINE | re.DOTALL)
if match:
    method_code = match.group(0)
    # Remove it from the original location
    content = content.replace(method_code, "")
    
    # Insert it right after the start of _SettingsScreenState
    target = "class _SettingsScreenState extends ConsumerState<SettingsScreen> {"
    content = content.replace(target, target + "\n\n" + method_code)
    
    with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
        f.write(content)
else:
    print("Method not found!")
