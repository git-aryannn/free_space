import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

import_str = "import 'package:free_space/presentation/widgets/confirm_detection_mode_change.dart';\n"
if "confirm_detection_mode_change.dart" not in content:
    content = content.replace("import 'package:free_space/presentation/widgets/operation_mode_confirmation.dart';", "import 'package:free_space/presentation/widgets/operation_mode_confirmation.dart';\n" + import_str)

target = r'''                          onSelectionChanged: _saving
                              \? null
                              : \(Set<DetectionMode> newSelection\) async \{
                                  setState\(\(\) => _saving = true\);
                                  try \{
                                    await ref
                                        \.read\(settingsRepositoryProvider\)
                                        \.setDetectionMode\(newSelection\.first\);'''

replacement = r'''                          onSelectionChanged: _saving
                              ? null
                              : (Set<DetectionMode> newSelection) async {
                                  final agreed = await confirmDetectionModeChange(
                                    context,
                                    currentMode: mode,
                                    newMode: newSelection.first,
                                  );
                                  if (!agreed || !mounted) return;
                                  
                                  setState(() => _saving = true);
                                  try {
                                    await ref
                                        .read(settingsRepositoryProvider)
                                        .setDetectionMode(newSelection.first);'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
