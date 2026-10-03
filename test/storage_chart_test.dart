import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_space/core/theme/app_theme.dart';
import 'package:free_space/data/repositories/storage_repository.dart';
import 'package:free_space/presentation/widgets/storage_chart.dart';

void main() {
  const storageInfo = StorageInfo(
    totalBytes: 100 * 1024 * 1024 * 1024,
    usedBytes: 72 * 1024 * 1024 * 1024,
    freeBytes: 28 * 1024 * 1024 * 1024,
  );

  testWidgets('storage ring and legend use visible dark theme colors',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              height: 300,
              width: 360,
              child: StorageChart(storageInfo: storageInfo),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chart = tester.widget<PieChart>(find.byType(PieChart));
    final sections = chart.data.sections;
    final scheme = AppTheme.darkTheme.colorScheme;

    expect(sections[0].color, scheme.primary);
    expect(sections[1].color, const Color(0xFF465160));
    expect(sections[0].color, isNot(sections[1].color));
    expect(find.text('Used'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('of')).style?.color,
      scheme.onSurfaceVariant,
    );
  });
}
