import re

with open("lib/presentation/providers/settings_provider.dart", "r") as f:
    content = f.read()

target = r'''final inactivityDaysProvider = FutureProvider<int>\(\(ref\) async \{
  final repository = ref\.watch\(settingsRepositoryProvider\);
  return repository\.getInactivityDays\(\);
\}\);'''

replacement = r'''final inactivityDaysProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getInactivityDays();
});

final detectionModeProvider = FutureProvider<DetectionMode>((ref) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getDetectionMode();
});'''

content = re.sub(target, replacement, content)

with open("lib/presentation/providers/settings_provider.dart", "w") as f:
    f.write(content)

