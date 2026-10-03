import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_space/data/repositories/settings_repository.dart';
import 'package:free_space/presentation/widgets/operation_mode_confirmation.dart';

void main() {
  testWidgets('requires agreement before enabling Auto-Bin', (tester) async {
    bool? confirmed;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                confirmed = await confirmOperationModeChange(
                  context,
                  currentMode: OperationMode.holdReview,
                  newMode: OperationMode.autoBin,
                  inactivityDays: 30,
                );
              },
              child: const Text('Change mode'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Change mode'));
    await tester.pumpAndSettle();
    expect(find.text('Turn on Auto-Bin?'), findsOneWidget);
    expect(
      find.textContaining(
        'Permanent items unused for 30 days will move to Temporary.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Disagree'));
    await tester.pumpAndSettle();
    expect(confirmed, isFalse);
  });

  testWidgets('applies a mode only after the user agrees', (tester) async {
    bool? confirmed;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                confirmed = await confirmOperationModeChange(
                  context,
                  currentMode: OperationMode.autoBin,
                  newMode: OperationMode.holdReview,
                  inactivityDays: 14,
                );
              },
              child: const Text('Change mode'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Change mode'));
    await tester.pumpAndSettle();
    expect(find.text('Switch to Hold & Review?'), findsOneWidget);
    await tester.tap(find.text('Agree'));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });
}
