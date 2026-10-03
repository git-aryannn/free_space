import 'dart:io' show Platform;
import 'package:free_space/presentation/providers/settings_provider.dart';
import 'package:free_space/data/services/background_live_service.dart';
import 'package:free_space/presentation/providers/items_provider.dart';
import 'package:free_space/data/repositories/item_repository.dart';
import 'package:free_space/data/repositories/settings_repository.dart';
import 'package:free_space/data/database/app_database.dart';
import 'package:free_space/data/models/item_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/app.dart';
import 'package:free_space/data/services/notification_service.dart';
import 'package:free_space/presentation/providers/notification_provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

void main() async {
  FlutterError.onError = (details) { print('FLUTTER ERROR: ${details.exceptionAsString()}'); };
  print('APP START: ensureInitialized');
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
    try {
      print('APP START: initializeBackgroundService');
      await initializeBackgroundService();
    } catch (e) {
      print('Background service init failed: $e');
    }
    
    try {
      print('APP START: initializeWorkManager');
      await initializeWorkManager();
    } catch (e) {
      print('WorkManager init failed: $e');
    }
  }

  late final NotificationService notificationService;
  print('APP START: Setting up ProviderContainer');
  final container = ProviderContainer(
    overrides: [
      notificationServiceProvider.overrideWith((ref) => notificationService),
    ],
  );

  final settingsRepo = container.read(settingsRepositoryProvider);
  print('APP START: getDetectionMode');
  final mode = await settingsRepo.getDetectionMode();

  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
    if (mode == DetectionMode.efficientBackground) {
      registerEfficientBackgroundTasks();
    }
  }

  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
    if (mode == DetectionMode.liveMonitoring) {
      FlutterBackgroundService().startService();
    } else {
      FlutterBackgroundService().invoke("stopService");
    }
  }
  notificationService = NotificationService(
    onActionTapped: (actionId, payload) async {
      final repo = container.read(itemRepositoryProvider);
      final category = actionId == 'KEEP_PERMANENT'
          ? ItemCategory.permanent
          : ItemCategory.temporary;

      final name = payload.split('/').last;
      await repo.trackNewFile(payload, category, name);
    },
  );

  print('APP START: runApp');
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FreeSpaceApp(),
    ),
  );
}
// I shouldn't append directly to the end of main.dart. Let's do it inside main().
