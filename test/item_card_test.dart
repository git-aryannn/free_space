import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_space/core/utils/file_utils.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'package:free_space/presentation/widgets/item_card.dart';

void main() {
  test('uses distinct icons for photo, video, files, and apps', () {
    final photoIcon = FileUtils.getIconForItem(
      type: ItemType.media,
      name: 'photo.jpg',
    );
    final videoIcon = FileUtils.getIconForItem(
      type: ItemType.media,
      name: 'video.mp4',
    );
    final fileIcon = FileUtils.getIconForItem(
      type: ItemType.file,
      name: 'notes.txt',
    );
    final appIcon = FileUtils.getIconForItem(
      type: ItemType.app,
      name: 'Free Space.app',
    );

    expect(photoIcon, Icons.photo_outlined);
    expect(videoIcon, Icons.movie_outlined);
    expect(fileIcon, Icons.description_outlined);
    expect(appIcon, Icons.apps_outlined);
    expect({photoIcon, videoIcon, fileIcon, appIcon}, hasLength(4));
  });

  testWidgets('shows how long ago an item was last accessed', (tester) async {
    final item = TrackedItemModel(
      id: 1,
      name: 'report.pdf',
      path: '/documents/report.pdf',
      type: ItemType.file,
      sizeBytes: 1024,
      category: ItemCategory.permanent,
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
      lastUsedAt: DateTime.now().subtract(const Duration(days: 12, hours: 1)),
      isFlagged: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ItemCard(item: item)),
      ),
    );

    expect(find.text('Not accessed for 12 days'), findsOneWidget);
  });

  testWidgets('shows today for items accessed today', (tester) async {
    final item = TrackedItemModel(
      id: 2,
      name: 'photo.jpg',
      path: '/photos/photo.jpg',
      type: ItemType.media,
      sizeBytes: 2048,
      category: ItemCategory.temporary,
      createdAt: DateTime.now(),
      lastUsedAt: DateTime.now(),
      isFlagged: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ItemCard(item: item)),
      ),
    );

    expect(find.text('Accessed today'), findsOneWidget);
    expect(find.text('30 d left'), findsOneWidget);
  });

  testWidgets('shows time left before a temporary item moves to Bin',
      (tester) async {
    final item = TrackedItemModel(
      id: 4,
      name: 'archive.zip',
      path: '/documents/archive.zip',
      type: ItemType.file,
      sizeBytes: 2048,
      category: ItemCategory.temporary,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      lastUsedAt: DateTime.now().subtract(const Duration(days: 12)),
      isFlagged: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(
            item: item,
            inactivityThresholdDays: 30,
          ),
        ),
      ),
    );

    expect(find.text('18 d left'), findsOneWidget);
    expect(
      find.text('18 days left to move into Bin automatically'),
      findsOneWidget,
    );
    final countdownTooltip = tester.widget<Tooltip>(
      find.ancestor(
        of: find.text('18 d left'),
        matching: find.byType(Tooltip),
      ),
    );
    expect(
      countdownTooltip.message,
      '18 days left to move into Bin automatically',
    );
    expect(find.text('12 d'), findsNothing);
  });

  testWidgets('shows a numeric zero-day auto-bin countdown instead of Due',
      (tester) async {
    final item = TrackedItemModel(
      id: 6,
      name: 'due.txt',
      path: '/documents/due.txt',
      type: ItemType.file,
      sizeBytes: 2048,
      category: ItemCategory.temporary,
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
      lastUsedAt: DateTime.now().subtract(const Duration(days: 30)),
      isFlagged: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(
            item: item,
            inactivityThresholdDays: 30,
          ),
        ),
      ),
    );

    expect(find.text('0 d left'), findsOneWidget);
    expect(
      find.text('0 days left to move into Bin automatically'),
      findsOneWidget,
    );
    expect(find.text('Due'), findsNothing);
  });

  testWidgets('starts a full countdown when an item enters Temporary',
      (tester) async {
    final item = TrackedItemModel(
      id: 7,
      name: 'recently-moved.txt',
      path: '/documents/recently-moved.txt',
      type: ItemType.file,
      sizeBytes: 2048,
      category: ItemCategory.temporary,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastUsedAt: DateTime.now().subtract(const Duration(days: 60)),
      temporarySince: DateTime.now(),
      isFlagged: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(
            item: item,
            inactivityThresholdDays: 30,
          ),
        ),
      ),
    );

    expect(find.text('30 d left'), findsOneWidget);
    expect(
      find.text('30 days left to move into Bin automatically'),
      findsOneWidget,
    );
  });

  testWidgets('shows time left before a binned item is permanently deleted',
      (tester) async {
    final item = TrackedItemModel(
      id: 5,
      name: 'old-photo.jpg',
      path: '/photos/old-photo.jpg',
      type: ItemType.media,
      sizeBytes: 4096,
      category: ItemCategory.binned,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastUsedAt: DateTime.now().subtract(const Duration(days: 60)),
      binnedAt: DateTime.now().subtract(const Duration(days: 28)),
      systemTrashPath: '/.Trash/old-photo.jpg',
      isFlagged: false,
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ItemCard(item: item))),
    );

    expect(find.text('2 d left'), findsOneWidget);
    expect(find.text('28 d ago'), findsNothing);
  });

  testWidgets('calls the reveal action on double click', (tester) async {
    var revealCount = 0;
    final item = TrackedItemModel(
      id: 3,
      name: 'notes.txt',
      path: '/documents/notes.txt',
      type: ItemType.file,
      sizeBytes: 100,
      category: ItemCategory.temporary,
      createdAt: DateTime.now(),
      lastUsedAt: DateTime.now(),
      isFlagged: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(item: item, onDoubleTap: () => revealCount++),
        ),
      ),
    );
    await tester.tap(find.text('notes.txt'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('notes.txt'));
    await tester.pumpAndSettle();

    expect(revealCount, 1);
  });
}
