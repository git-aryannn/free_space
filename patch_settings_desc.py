import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

# Info block template
def info_block(text):
    return f"""                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '{text}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),"""


# 1. Update Automatic Item Movement
# We need to wrap its child (SegmentedButton) in a Column and add the info block.
auto_move_text = "Hold & Review Mode:\\nItems unused for the inactivity threshold move to Temporary and stay there until you review them.\\n\\nAuto-bin Mode:\\nItems unused for the threshold move to Temporary. If unused again for the same threshold duration, they automatically move to the Bin."

# Replace the child of Automatic Item Movement
if "child: SegmentedButton<OperationMode>(" in content:
    # Find the end of SegmentedButton
    start_idx = content.find("child: SegmentedButton<OperationMode>(")
    # Just wrap it manually with regex. It's safer to just replace the whole section to avoid brace matching in regex.
    # Actually, we can use regex to find the end of the _SettingsCard.

