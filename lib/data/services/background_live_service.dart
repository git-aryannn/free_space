import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/presentation/providers/items_provider.dart';
import 'package:free_space/presentation/providers/database_provider.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:free_space/data/database/app_database.dart';
import 'package:free_space/data/repositories/item_repository.dart';
import 'package:free_space/data/repositories/settings_repository.dart';
import 'package:free_space/data/services/sync_service.dart';
import 'package:free_space/data/services/notification_service.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  // Request permissions if not already done, etc.
  final notificationService = NotificationService();
  await notificationService.init();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'free_space_channel',
      initialNotificationTitle: 'Free Space Live Mode',
      initialNotificationContent:
          'Monitoring for new files in the background...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Initialize via Riverpod container in background isolate
  final container = ProviderContainer();
  final itemRepo = container.read(itemRepositoryProvider);
  final settingsRepo = container.read(settingsRepositoryProvider);
  final syncService = container.read(syncServiceProvider);
  final notificationService = NotificationService();
  await notificationService.init();

  int lastInboxCount = 0;

  // Poll every 5 seconds
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    // Check if mode is still live monitoring
    final mode = await settingsRepo.getDetectionMode();
    if (mode != DetectionMode.liveMonitoring) {
      service.stopSelf();
      return;
    }

    try {
      final beforeItems = await settingsRepo.getInboxItems();
      final beforeCount = beforeItems.length;
      await syncService.performSync(force: true);
      final afterItems = await settingsRepo.getInboxItems();
      final afterCount = afterItems.length;

      if (afterCount > beforeCount) {
        lastInboxCount = afterCount;
        final newCount = afterCount - beforeCount;
        if (newCount == 1) {
          final newItem = afterItems.last;
          await notificationService.showNewItemNotification(
              newItem.name, newItem.path, newItem.sizeBytes);
        } else {
          await notificationService.showReminderNotification(newCount);
        }
      }
    } catch (e) {
      // Ignore background errors
    }
  });
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // This is called by Workmanager
    DartPluginRegistrant.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize via Riverpod container in background isolate
    final container = ProviderContainer();
    final itemRepo = container.read(itemRepositoryProvider);
    final settingsRepo = container.read(settingsRepositoryProvider);
    final syncService = container.read(syncServiceProvider);
    final notificationService = NotificationService();
    await notificationService.init();

    try {
      final mode = await settingsRepo.getDetectionMode();
      if (mode != DetectionMode.efficientBackground) {
        return Future.value(true);
      }

      final beforeItems = await settingsRepo.getInboxItems();
      final beforeCount = beforeItems.length;
      await syncService.performSync(force: true);
      final afterItems = await settingsRepo.getInboxItems();
      final afterCount = afterItems.length;

      if (afterCount > beforeCount) {
        final newCount = afterCount - beforeCount;
        if (newCount == 1) {
          final newItem = afterItems.last;
          await notificationService.showNewItemNotification(
              newItem.name, newItem.path, newItem.sizeBytes);
        } else {
          await notificationService.showReminderNotification(newCount);
        }
      }
    } catch (e) {
      // Ignored
    }

    return Future.value(true);
  });
}

Future<void> initializeWorkManager() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
}

void registerEfficientBackgroundTasks() {
  Workmanager().registerPeriodicTask(
    "efficient-sync-task",
    "freeSpaceSync",
    frequency: const Duration(minutes: 15), // Minimum allowed by Android
    constraints: Constraints(
      requiresBatteryNotLow: true,
      requiresDeviceIdle: false,
    ),
  );
}
