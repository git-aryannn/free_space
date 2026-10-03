import 'package:flutter/material.dart';
import 'package:free_space/data/repositories/settings_repository.dart';

Future<bool> confirmDetectionModeChange(
  BuildContext context, {
  required DetectionMode currentMode,
  required DetectionMode newMode,
}) async {
  if (currentMode == newMode) return true;

  final colorScheme = Theme.of(context).colorScheme;

  String title = '';
  String content = '';
  IconData icon = Icons.sync;

  switch (newMode) {
    case DetectionMode.smartSync:
      title = 'Turn on Smart Sync?';
      content =
          'Zero battery drain. The app silently scans for new items only when you open the app.';
      icon = Icons.sync;
      break;
    case DetectionMode.efficientBackground:
      title = 'Turn on Efficient Mode?';
      content =
          'Android wakes the app occasionally when files are added in the background. 0 battery drain, but notifications may be slightly delayed.';
      icon = Icons.schedule;
      break;
    case DetectionMode.liveMonitoring:
      title = 'Turn on Live Mode?';
      content =
          'The app stays awake in the background and instantly alerts you of new files. May consume slight battery.';
      icon = Icons.flash_on;
      break;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        icon,
        color: colorScheme.primary,
      ),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Disagree'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Agree'),
        ),
      ],
    ),
  );
  return confirmed == true;
}
