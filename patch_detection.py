import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = r'''              _SettingsCard\(
                title: 'New File Detection',
                subtitle: 'How the app detects newly created items.',
                currentValue: \(detectionModeAsync.valueOrNull \?\? DetectionMode.smartSync\) == DetectionMode.smartSync \? 'Smart Sync \(Battery Saver\)' : 'Live Mode \(Instant\)',
                icon: Icons.sync,
                child: detectionModeAsync.when\(
                  data: \(mode\) \{
                    return Column\(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: \[
                        SegmentedButton<DetectionMode>\(
                          segments: const \[
                            ButtonSegment\(
                              value: DetectionMode.smartSync,
                              label: Text\('Smart Sync\\n\(Battery Saver\)', textAlign: TextAlign.center, style: TextStyle\(fontSize: 12\)\),
                              icon: Icon\(Icons.sync\),
                            \),
                            ButtonSegment\(
                              value: DetectionMode.liveMonitoring,
                              label: Text\('Live Mode\\n\(Instant\)', textAlign: TextAlign.center, style: TextStyle\(fontSize: 12\)\),
                              icon: Icon\(Icons.flash_on\),
                            \),
                          \],
                          selected: \{mode\},
                          onSelectionChanged: _saving
                              \? null
                              : \(Set<DetectionMode> newSelection\) async \{
                                  setState\(\(\) => _saving = true\);
                                  try \{
                                    await ref
                                        .read\(settingsRepositoryProvider\)
                                        .setDetectionMode\(newSelection.first\);
                                    ref.invalidate\(detectionModeProvider\);
                                  \} catch \(error\) \{
                                    if \(mounted\) \{
                                      ScaffoldMessenger.of\(context\)
                                          .showSnackBar\(
                                        SnackBar\(
                                            content: Text\(
                                                'Error saving mode: \$error'\)\),
                                      \);
                                    \}
                                  \} finally \{
                                    if \(mounted\) \{
                                      setState\(\(\) => _saving = false\);
                                    \}
                                  \}
                                \},
                        \),
                        const SizedBox\(height: 16\),
                        Container\(
                          padding: const EdgeInsets.all\(12\),
                          decoration: BoxDecoration\(
                            color: theme.colorScheme.surfaceContainerHighest.withValues\(alpha: 0.5\),
                            borderRadius: BorderRadius.circular\(12\),
                            border: Border.all\(color: theme.colorScheme.outlineVariant.withValues\(alpha: 0.5\)\),
                          \),
                          child: Text\(
                            'Smart Sync \(Recommended\):\\nZero battery drain. The app silently scans for new items \(Downloads, Screenshots, Camera\) only when you open the app.\\n\\nLive Mode:\\nThe app stays awake in the background and instantly alerts you as soon as a new file is created on your device. May consume slight battery.',
                            style: theme.textTheme.bodySmall,
                          \),
                        \),
                      \],
                    \);
                  \},
                  loading: \(\) => const CircularProgressIndicator\(\),
                  error: \(err, stack\) => Text\('Error: \$err'\),
                \),
              \),'''

replacement = r'''              _SettingsCard(
                title: 'New File Detection',
                subtitle: 'How the app detects newly created items.',
                currentValue: (detectionModeAsync.valueOrNull ?? DetectionMode.smartSync) == DetectionMode.smartSync 
                  ? 'Smart Sync (Battery Saver)' 
                  : (detectionModeAsync.valueOrNull == DetectionMode.efficientBackground 
                      ? 'Efficient (Background)' 
                      : 'Live Mode (Instant)'),
                icon: Icons.sync,
                child: detectionModeAsync.when(
                  data: (mode) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SegmentedButton<DetectionMode>(
                          segments: const [
                            ButtonSegment(
                              value: DetectionMode.smartSync,
                              label: Text('Smart Sync\n(On open)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                              icon: Icon(Icons.sync),
                            ),
                            ButtonSegment(
                              value: DetectionMode.efficientBackground,
                              label: Text('Efficient\n(Background)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                              icon: Icon(Icons.schedule),
                            ),
                            ButtonSegment(
                              value: DetectionMode.liveMonitoring,
                              label: Text('Live Mode\n(Instant)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                              icon: Icon(Icons.flash_on),
                            ),
                          ],
                          selected: {mode},
                          onSelectionChanged: _saving
                              ? null
                              : (Set<DetectionMode> newSelection) async {
                                  setState(() => _saving = true);
                                  try {
                                    await ref
                                        .read(settingsRepositoryProvider)
                                        .setDetectionMode(newSelection.first);
                                    ref.invalidate(detectionModeProvider);
                                    
                                    // Handle Service state
                                    final service = FlutterBackgroundService();
                                    if (newSelection.first == DetectionMode.liveMonitoring) {
                                      service.startService();
                                    } else {
                                      // Efficient mode uses workmanager, not foreground service
                                      service.invoke("stopService");
                                    }
                                  } catch (error) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Error saving mode: $error')),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _saving = false);
                                    }
                                  }
                                },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'Smart Sync (Battery Saver):\nZero battery drain. The app silently scans for new items only when you open the app.\n\nEfficient Mode (Background):\nAndroid wakes the app occasionally when files are added. 0 battery drain, but notifications may be slightly delayed.\n\nLive Mode (Instant):\nThe app stays awake in the background and instantly alerts you. May consume slight battery.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text('Error: $err'),
                ),
              ),'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
