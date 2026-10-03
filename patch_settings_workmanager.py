import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = r'''                                    // Handle Service state
                                    final service = FlutterBackgroundService\(\);
                                    if \(newSelection.first == DetectionMode.liveMonitoring\) \{
                                      service.startService\(\);
                                    \} else \{
                                      // Efficient mode uses workmanager, not foreground service
                                      service.invoke\("stopService"\);
                                    \}'''

replacement = r'''                                    // Handle Service state
                                    final service = FlutterBackgroundService();
                                    if (newSelection.first == DetectionMode.liveMonitoring) {
                                      service.startService();
                                      Workmanager().cancelAll();
                                    } else if (newSelection.first == DetectionMode.efficientBackground) {
                                      service.invoke("stopService");
                                      Workmanager().registerPeriodicTask(
                                        "efficient-sync-task",
                                        "freeSpaceSync",
                                        frequency: const Duration(minutes: 15),
                                        constraints: Constraints(
                                          networkType: NetworkType.not_required,
                                          requiresBatteryNotLow: true,
                                          requiresDeviceIdle: false,
                                        ),
                                      );
                                    } else {
                                      service.invoke("stopService");
                                      Workmanager().cancelAll();
                                    }'''

content = re.sub(target, replacement, content)

if "import 'package:workmanager/workmanager.dart';" not in content:
    content = "import 'package:workmanager/workmanager.dart';\n" + content

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
