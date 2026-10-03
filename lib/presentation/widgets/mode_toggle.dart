import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/data/repositories/settings_repository.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';
import 'package:free_space/presentation/widgets/operation_mode_confirmation.dart';

/// A toggle widget for switching between Auto-Bin and Hold & Review modes.
class ModeToggle extends ConsumerWidget {
  const ModeToggle({super.key});

  Future<void> _requestModeChange(
    BuildContext context,
    WidgetRef ref,
    OperationMode currentMode,
    OperationMode newMode,
    int inactivityDays,
  ) async {
    final agreed = await confirmOperationModeChange(
      context,
      currentMode: currentMode,
      newMode: newMode,
      inactivityDays: inactivityDays,
    );
    if (!agreed || !context.mounted) return;
    try {
      await ref.read(settingsRepositoryProvider).setOperationMode(newMode);
      ref.invalidate(operationModeProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save operation mode: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(operationModeProvider);
    final inactivityDays = ref.watch(inactivityDaysProvider).valueOrNull ?? 30;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<OperationMode>(
          segments: const [
            ButtonSegment(
              value: OperationMode.autoBin,
              icon: Icon(Icons.auto_delete),
              label: FittedBox(
                  fit: BoxFit.scaleDown, child: Text('Auto-Bin', maxLines: 1)),
            ),
            ButtonSegment(
              value: OperationMode.holdReview,
              icon: Icon(Icons.preview),
              label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Hold & Review', maxLines: 1)),
            ),
          ],
          selected: {currentMode.valueOrNull ?? OperationMode.holdReview},
          onSelectionChanged: (newSelection) => _requestModeChange(
            context,
            ref,
            currentMode.valueOrNull ?? OperationMode.holdReview,
            newSelection.first,
            inactivityDays,
          ),
          style: SegmentedButton.styleFrom(
            selectedForegroundColor: colorScheme.onPrimary,
            selectedBackgroundColor: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          currentMode.valueOrNull == OperationMode.autoBin
              ? 'Permanent items unused for $inactivityDays days move to Temporary. Temporary items move to Bin after $inactivityDays days in either mode.'
              : 'Permanent items stay here until you move them. Temporary items move to Bin after $inactivityDays days.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
