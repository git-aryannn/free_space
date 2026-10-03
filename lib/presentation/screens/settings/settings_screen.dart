import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:go_router/go_router.dart';
import 'package:free_space/core/theme/app_colors.dart';
import 'package:free_space/data/repositories/settings_repository.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';
import 'package:free_space/presentation/providers/database_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:free_space/presentation/widgets/operation_mode_confirmation.dart';
import 'package:free_space/presentation/widgets/confirm_detection_mode_change.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Widget _buildIgnoredFoldersSection(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Consumer(
      builder: (context, ref, child) {
        final ignoredPathsAsync = ref.watch(ignoredPathsProvider);
        final pathsCount = ignoredPathsAsync.valueOrNull?.length ?? 0;
        final pathsList = ignoredPathsAsync.valueOrNull ?? [];
        final currentValueText =
            pathsCount == 0 ? 'Not selected' : '$pathsCount selected';
        return _SettingsCard(
          title: 'Ignored Folders',
          subtitle: 'These folders will never be scanned.',
          currentValue: currentValueText,
          icon: Icons.folder_off_outlined,
          child: Column(
            children: [
              ignoredPathsAsync.when(
                data: (paths) {
                  if (paths.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No folders ignored yet.'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paths.length,
                    itemBuilder: (context, index) {
                      final path = paths[index];
                      return ListTile(
                        dense: true,
                        title: Text(path, style: const TextStyle(fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () {
                            ref
                                .read(appSettingsDaoProvider)
                                .removeIgnoredPath(path);
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
                error: (e, s) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading paths: $e'),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    try {
                      final path = await FilePicker.getDirectoryPath(
                        dialogTitle: 'Select Folder to Ignore',
                      );
                      if (path != null && path.isNotEmpty) {
                        ref.read(appSettingsDaoProvider).addIgnoredPath(path);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to pick folder: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Folder'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  int? _draftInactivityDays;
  bool _saving = false;
  bool _isEditingInactivity = false;

  Future<void> _saveInactivityDays(int days) async {
    setState(() {
      _saving = true;
    });
    try {
      await ref.read(settingsRepositoryProvider).setInactivityDays(days);
      ref.invalidate(inactivityDaysProvider);
      if (mounted) {
        setState(() {
          _draftInactivityDays = null;
          _saving = false;
          _isEditingInactivity = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
        });
        _showError('Could not save inactivity threshold', error);
      }
    }
  }

  Future<void> _resetDefaults() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset settings?'),
        content: const Text(
          'This will restore the system theme, Hold & Review mode, and a '
          '30-day inactivity threshold.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (shouldReset != true || !mounted) return;

    setState(() {
      _saving = true;
      _draftInactivityDays = 30;
    });
    try {
      await ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
      final repository = ref.read(settingsRepositoryProvider);
      await repository.setOperationMode(OperationMode.holdReview);
      await repository.setInactivityDays(30);
      ref.invalidate(inactivityDaysProvider);
      if (mounted) {
        setState(() {
          _draftInactivityDays = null;
          _saving = false;
          _isEditingInactivity = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings restored to defaults')),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
        });
        _showError('Could not reset settings', error);
      }
    }
  }

  void _showError(String message, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final operationMode = ref.watch(operationModeProvider);
    final inactivityDaysAsync = ref.watch(inactivityDaysProvider);
    final detectionModeAsync = ref.watch(detectionModeProvider);
    final savedDays = inactivityDaysAsync.valueOrNull ?? 30;
    final inactivityDays = _draftInactivityDays ?? savedDays;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => context.go('/'),
        ),
        title: const Text('Settings'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text(
                'PREFERENCES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Make Free Space yours',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose how the app looks and how it handles inactive items.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _SettingsCard(
                title: 'Appearance',
                subtitle: 'Choose your preferred app theme.',
                currentValue:
                    '${themeMode.name[0].toUpperCase()}${themeMode.name.substring(1)}',
                icon: Icons.palette_outlined,
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('System', maxLines: 1)),
                      icon: Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Light', maxLines: 1)),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Dark', maxLines: 1)),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) async {
                    try {
                      await ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(selection.first);
                    } catch (error) {
                      if (mounted) _showError('Could not save theme', error);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Automatic Item Movement',
                subtitle: 'Choose whether inactive items auto-move.',
                currentValue:
                    operationMode.valueOrNull == OperationMode.holdReview
                        ? 'Review First'
                        : 'Auto-bin',
                icon: Icons.auto_delete_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<OperationMode>(
                      segments: const [
                        ButtonSegment(
                          value: OperationMode.holdReview,
                          label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Review first', maxLines: 1)),
                          icon: Icon(Icons.fact_check_outlined),
                        ),
                        ButtonSegment(
                          value: OperationMode.autoBin,
                          label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Auto-bin', maxLines: 1)),
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'Hold & Review Mode:\nItems unused for the inactivity threshold move to Temporary and stay there until you review them.\n\nAuto-bin Mode:\nItems unused for the threshold move to Temporary. If unused again for the same threshold duration, they automatically move to the Bin.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'New File Detection',
                subtitle: 'How the app detects newly created items.',
                currentValue: (detectionModeAsync.valueOrNull ??
                            DetectionMode.smartSync) ==
                        DetectionMode.smartSync
                    ? 'Smart Sync (Battery Saver)'
                    : (detectionModeAsync.valueOrNull ==
                            DetectionMode.efficientBackground
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
                              label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Smart Sync',
                                      maxLines: 1,
                                      style: TextStyle(fontSize: 12))),
                              icon: Icon(Icons.sync),
                            ),
                            ButtonSegment(
                              value: DetectionMode.efficientBackground,
                              label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Efficient',
                                      maxLines: 1,
                                      style: TextStyle(fontSize: 12))),
                              icon: Icon(Icons.schedule),
                            ),
                            ButtonSegment(
                              value: DetectionMode.liveMonitoring,
                              label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Live Mode',
                                      maxLines: 1,
                                      style: TextStyle(fontSize: 12))),
                              icon: Icon(Icons.flash_on),
                            ),
                          ],
                          selected: {mode},
                          onSelectionChanged: _saving
                              ? null
                              : (Set<DetectionMode> newSelection) async {
                                  final agreed =
                                      await confirmDetectionModeChange(
                                    context,
                                    currentMode: mode,
                                    newMode: newSelection.first,
                                  );
                                  if (!agreed || !mounted) return;

                                  setState(() => _saving = true);
                                  try {
                                    await ref
                                        .read(settingsRepositoryProvider)
                                        .setDetectionMode(newSelection.first);
                                    ref.invalidate(detectionModeProvider);

                                    // Handle Service state
                                    final service = FlutterBackgroundService();
                                    if (newSelection.first ==
                                        DetectionMode.liveMonitoring) {
                                      service.startService();
                                      Workmanager().cancelAll();
                                    } else if (newSelection.first ==
                                        DetectionMode.efficientBackground) {
                                      service.invoke("stopService");
                                      Workmanager().registerPeriodicTask(
                                        "efficient-sync-task",
                                        "freeSpaceSync",
                                        frequency: const Duration(minutes: 15),
                                        constraints: Constraints(
                                          networkType: NetworkType.connected,
                                          requiresBatteryNotLow: true,
                                          requiresDeviceIdle: false,
                                        ),
                                      );
                                    } else {
                                      service.invoke("stopService");
                                      Workmanager().cancelAll();
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
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5)),
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'This threshold determines how long a file must remain untouched before the app considers it "inactive".\n\n• Any time you view or open a file, its countdown resets to zero.\n• Items in the Bin are permanently deleted after 30 days (this is fixed and cannot be changed).',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildIgnoredFoldersSection(context, theme, colorScheme),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'About',
                subtitle: 'App information and third-party notices.',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.verified_outlined),
                      title: Text('Free Space'),
                      subtitle: Text('Version 1.0.0 (build 1)'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Open-source licenses'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showLicensePage(
                          context: context,
                          applicationName: 'Free Space',
                          applicationVersion: '1.0.0',
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _saving ? null : _resetDefaults,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset to defaults'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? currentValue;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;

  const _SettingsCard({
    required this.title,
    required this.subtitle,
    this.currentValue,
    required this.icon,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.gold,
            size: 21,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: currentValue != null
            ? Text(
                currentValue!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
