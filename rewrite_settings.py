import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

# Make currentValue optional in _SettingsCard so we don't break 'About'
content = content.replace("  final String currentValue;", "  final String? currentValue;")
content = content.replace("    required this.currentValue,", "    this.currentValue,")
content = content.replace("        subtitle: Text(\n          '$subtitle\\nCurrent: $currentValue',", "        subtitle: Text(\n          currentValue != null ? '$subtitle\\nCurrent: $currentValue' : subtitle,")

# Now let's extract and replace the big block.
# We will use string manipulation instead of regex to avoid missing edge cases.

# Find start of Automatic item movement card
start_idx = content.find("              _SettingsCard(\n                title: 'Automatic item movement',")
end_idx = content.find("              _SettingsCard(\n                title: 'About',")

if start_idx != -1 and end_idx != -1:
    before = content[:start_idx]
    after = content[end_idx:]
    
    new_cards = '''              _SettingsCard(
                title: 'Automatic Item Movement',
                subtitle: 'Choose whether inactive items auto-move.',
                currentValue: operationMode.valueOrNull == OperationMode.holdReview ? 'Review First' : 'Auto-bin',
                icon: Icons.auto_delete_outlined,
                child: SegmentedButton<OperationMode>(
                  segments: const [
                    ButtonSegment(
                      value: OperationMode.holdReview,
                      label: Text('Review first'),
                      icon: Icon(Icons.fact_check_outlined),
                    ),
                    ButtonSegment(
                      value: OperationMode.autoBin,
                      label: Text('Auto-bin'),
                      icon: Icon(Icons.delete_sweep_outlined),
                    ),
                  ],
                  selected: {
                    operationMode.valueOrNull ?? OperationMode.holdReview,
                  },
                  onSelectionChanged: (selection) async {
                    final currentMode = operationMode.valueOrNull ??
                        OperationMode.holdReview;
                    final agreed = await confirmOperationModeChange(
                      context,
                      currentMode: currentMode,
                      newMode: selection.first,
                      inactivityDays:
                          ref.read(inactivityDaysProvider).valueOrNull ??
                              30,
                    );
                    if (!agreed || !mounted) return;
                    try {
                      await ref
                          .read(settingsRepositoryProvider)
                          .setOperationMode(selection.first);
                        ref.invalidate(operationModeProvider);
                    } catch (error) {
                      if (mounted) {
                        _showError('Could not save operation mode', error);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'New File Detection',
                subtitle: 'How the app detects newly created items.',
                currentValue: (detectionModeAsync.valueOrNull ?? DetectionMode.smartSync) == DetectionMode.smartSync ? 'Smart Sync (Battery Saver)' : 'Live Mode (Instant)',
                icon: Icons.sync,
                child: detectionModeAsync.when(
                  data: (mode) {
                    return SegmentedButton<DetectionMode>(
                      segments: const [
                        ButtonSegment(
                          value: DetectionMode.smartSync,
                          label: Text('Smart Sync\\n(Battery Saver)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.sync),
                        ),
                        ButtonSegment(
                          value: DetectionMode.liveMonitoring,
                          label: Text('Live Mode\\n(Instant)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
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
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Inactivity Threshold',
                subtitle: 'How many days until an item is marked inactive.',
                currentValue: '$inactivityDays days',
                icon: Icons.timer_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Drag slider to change threshold',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        if (!_isEditingInactivity) ...[
                          Text(
                            '$inactivityDays days',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => setState(() {
                              _isEditingInactivity = true;
                              _draftInactivityDays = savedDays;
                            }),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: () => setState(() {
                              _isEditingInactivity = false;
                              _draftInactivityDays = null;
                            }),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _saving
                                ? null
                                : () async {
                                    setState(() => _saving = true);
                                    try {
                                      await ref
                                          .read(settingsRepositoryProvider)
                                          .setInactivityDays(
                                              _draftInactivityDays!);
                                      ref.invalidate(inactivityDaysProvider);
                                    } catch (error) {
                                      if (mounted) {
                                        _showError(
                                            'Could not save threshold', error);
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _saving = false;
                                          _isEditingInactivity = false;
                                        });
                                      }
                                    }
                                  },
                            child: _saving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Save'),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: inactivityDays.toDouble(),
                      min: 1,
                      max: 90,
                      divisions: 89,
                      label: '$inactivityDays days',
                      onChanged: _isEditingInactivity
                          ? (value) => setState(
                              () => _draftInactivityDays = value.round())
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Hold & Review Mode:\\nItems unused for this threshold will move from Permanent to Temporary.\\n\\nAuto-Bin Mode:\\nItems unused for this threshold will move from Permanent to Temporary, and if they remain unused in Temporary for another threshold duration, they automatically move to Bin.\\n\\n• Any view/open resets the countdown.\\n• Items in the Bin are permanently deleted after 30 days (this is fixed and cannot be changed).',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
'''
    
    with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
        f.write(before + new_cards + after)

