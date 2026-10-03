import re

with open("lib/main.dart", "r") as f:
    content = f.read()

target = r'''  final db = AppDatabase\(\);
  final settingsRepo = SettingsRepository\(db.settingsDao\);
  final mode = await settingsRepo.getDetectionMode\(\);
  
  if \(mode == DetectionMode.efficientBackground\) \{
    registerEfficientBackgroundTasks\(\);
  \}
  
  // Clean up if we are starting in a different mode
  if \(mode == DetectionMode.liveMonitoring\) \{
    FlutterBackgroundService\(\).startService\(\);
  \} else \{
    FlutterBackgroundService\(\).invoke\("stopService"\);
  \}'''

content = re.sub(target, "", content)

container_setup = r'''  final container = ProviderContainer(
    overrides: [
      notificationServiceProvider.overrideWith((ref) => notificationService),
    ],
  );'''

new_setup = container_setup + r'''
  
  final settingsRepo = container.read(settingsRepositoryProvider);
  final mode = await settingsRepo.getDetectionMode();
  
  if (mode == DetectionMode.efficientBackground) {
    registerEfficientBackgroundTasks();
  }
  
  if (mode == DetectionMode.liveMonitoring) {
    FlutterBackgroundService().startService();
  } else {
    FlutterBackgroundService().invoke("stopService");
  }'''

content = content.replace(container_setup, new_setup)

if "import 'package:free_space/presentation/providers/settings_provider.dart';" not in content:
    content = "import 'package:free_space/presentation/providers/settings_provider.dart';\n" + content

with open("lib/main.dart", "w") as f:
    f.write(content)
