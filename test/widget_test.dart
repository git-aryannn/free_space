import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_space/app.dart';
import 'package:free_space/data/database/app_database.dart';
import 'package:free_space/presentation/providers/database_provider.dart';
import 'package:free_space/presentation/widgets/item_action_helpers.dart';

void main() {
  testWidgets('launches into the onboarding flow', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const FreeSpaceApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Free Space'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });

  testWidgets('requests all-files access only after user consent',
      (WidgetTester tester) async {
    const channel = MethodChannel('com.freespace.app/platform');
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return switch (call.method) {
        'hasAllFilesAccess' => false,
        'requestAllFilesAccess' => true,
        _ => null,
      };
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    bool? granted;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Builder(
            builder: (context) => Consumer(
              builder: (context, ref, _) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    granted = await ensureAllFilesAccess(context, ref);
                  },
                  child: const Text('Move PDF to Bin'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Move PDF to Bin'));
    await tester.pumpAndSettle();
    expect(find.text('Allow access to manage files?'), findsOneWidget);
    expect(calls, ['hasAllFilesAccess']);

    await tester.tap(find.text('Continue to Settings'));
    await tester.pumpAndSettle();
    expect(granted, isTrue);
    expect(calls, ['hasAllFilesAccess', 'requestAllFilesAccess']);
  });

  testWidgets('does not request system access when user declines',
      (WidgetTester tester) async {
    const channel = MethodChannel('com.freespace.app/platform');
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return false;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    bool? granted;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Builder(
            builder: (context) => Consumer(
              builder: (context, ref, _) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    granted = await ensureAllFilesAccess(context, ref);
                  },
                  child: const Text('Move PDF to Bin'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Move PDF to Bin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(granted, isFalse);
    expect(calls, ['hasAllFilesAccess']);
  });
}
