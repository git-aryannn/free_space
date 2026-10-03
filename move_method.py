import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

# The class ends with a closing brace `}` before my appended method.
# Let's extract the appended method
parts = content.split("  Widget _buildIgnoredFoldersSection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {")
if len(parts) == 2:
    method_code = "  Widget _buildIgnoredFoldersSection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {" + parts[1]
    
    # Remove the method from the end
    original = parts[0]
    
    # Remove the last closing brace of the original class (which is the last '}')
    last_brace_idx = original.rfind('}')
    if last_brace_idx != -1:
        new_content = original[:last_brace_idx] + "\n" + method_code + "\n}\n"
        with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
            f.write(new_content)

