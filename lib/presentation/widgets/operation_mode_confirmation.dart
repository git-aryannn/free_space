import 'package:flutter/material.dart';
import 'package:free_space/data/repositories/settings_repository.dart';

Future<bool> confirmOperationModeChange(
  BuildContext context, {
  required OperationMode currentMode,
  required OperationMode newMode,
  required int inactivityDays,
}) async {
  if (currentMode == newMode) return true;

  final colorScheme = Theme.of(context).colorScheme;
  final isAutoBin = newMode == OperationMode.autoBin;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        isAutoBin ? Icons.auto_delete_outlined : Icons.fact_check_outlined,
        color: colorScheme.primary,
      ),
      title: Text(isAutoBin ? 'Turn on Auto-Bin?' : 'Switch to Hold & Review?'),
      content: Text(
        isAutoBin
            ? 'Permanent items unused for $inactivityDays days will move to '
                'Temporary. After another $inactivityDays days there, items '
                'will move to Bin automatically.'
            : 'Permanent items will stay in Permanent until you move them. '
                'Items already in Temporary will still move to Bin after '
                '$inactivityDays days.',
      ),
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
