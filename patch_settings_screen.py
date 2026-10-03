import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

# Add detectionModeProvider watch
target = r'''    final inactivityDaysAsync = ref\.watch\(inactivityDaysProvider\);
    final themeModeAsync = ref\.watch\(themeModeProvider\);'''

replacement = r'''    final inactivityDaysAsync = ref.watch(inactivityDaysProvider);
    final themeModeAsync = ref.watch(themeModeProvider);
    final detectionModeAsync = ref.watch(detectionModeProvider);'''

content = re.sub(target, replacement, content)


# Add Detection Mode UI
target_ui = r'''                    Row\(
                      children: \[
                        Expanded\('''

replacement_ui = r'''                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'New File Detection Mode',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    detectionModeAsync.when(
                      data: (mode) {
                        return SegmentedButton<DetectionMode>(
                          segments: const [
                            ButtonSegment(
                              value: DetectionMode.smartSync,
                              label: Text('Smart Sync\n(Battery Saver)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                              icon: Icon(Icons.sync),
                            ),
                            ButtonSegment(
                              value: DetectionMode.liveMonitoring,
                              label: Text('Live Mode\n(Instant)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
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
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded('''

content = re.sub(target_ui, replacement_ui, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)

