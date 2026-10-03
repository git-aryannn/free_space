import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

# 1. Automatic Item Movement
# Let's add the info block after the segmented button.
target_auto_move = r'''                child: SegmentedButton<OperationMode>\(.*?onSelectionChanged:.*?\},
                \),'''
new_auto_move = r'''                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<OperationMode>(
                      // ... segmented button ... (will replace dynamically using python logic below)
'''

