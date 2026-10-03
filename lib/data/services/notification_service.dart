import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as developer;

/// A service to handle local notifications.
class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Future<void>? _initialization;

  /// Initializes the notification service with platform-specific settings.
  Future<void> init() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    if (_initialized) return;
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onNotificationAction,
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await init();
    final androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }
    final darwinPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
    return await darwinPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  final Function(String actionId, String payload)? onActionTapped;

  NotificationService({this.onActionTapped});

  @pragma('vm:entry-point')
  static void _onNotificationAction(NotificationResponse response) async {
    developer.log(
        'Background action tapped: ${response.actionId} payload: ${response.payload}');
    if (response.actionId != null && response.payload != null) {
      // In a real production app, we would initialize the database here using a shared isolate
      // or recreate the Drift database connection to insert the item.
      // But because Riverpod's DB provider initializes the connection uniquely (e.g. using path_provider),
      // doing it here requires importing those and duplicating the DB setup logic.
      developer.log(
          'Need DB setup to save to ${response.actionId} for ${response.payload}');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
        'Notification tapped with payload: ${response.payload} action: ${response.actionId}');
    if (response.actionId != null && response.payload != null) {
      onActionTapped?.call(response.actionId!, response.payload!);
    }
  }

  NotificationDetails _getNewItemNotificationDetails(String path) {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'free_space_channel_items',
      'New Items',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('KEEP_PERMANENT', 'Keep in Permanent'),
        const AndroidNotificationAction('MOVE_TEMPORARY', 'Move to Temporary'),
      ],
    );
    const darwinPlatformChannelSpecifics = DarwinNotificationDetails();
    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
      macOS: darwinPlatformChannelSpecifics,
    );
  }

  NotificationDetails _getNotificationDetails() {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'free_space_channel',
      'Free Space Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails();
    return const NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
      macOS: darwinPlatformChannelSpecifics,
    );
  }

  /// Shows a notification when a new item is detected.
  Future<void> showNewItemNotification(
      String itemName, String path, int sizeBytes) async {
    await init();

    // Format size
    final sizeMb = (sizeBytes / (1024 * 1024)).toStringAsFixed(1);

    await _flutterLocalNotificationsPlugin.show(
      id: path.hashCode, // Unique ID per file
      title: 'New Download Detected',
      body: '$itemName ($sizeMb MB)',
      notificationDetails: _getNewItemNotificationDetails(path),
      payload: path,
    );
  }

  /// Shows a notification about items automatically moved to the Bin.
  Future<void> showBinNotification(int count) async {
    if (count <= 0) return;
    await init();
    final message = count == 1
        ? 'An item moved to Bin automatically. Review it when you have a moment.'
        : '$count items moved to Bin automatically. Review them when you have a moment.';
    await _flutterLocalNotificationsPlugin.show(
      id: 1,
      title: 'Some items moved to Bin',
      body: message,
      notificationDetails: _getNotificationDetails(),
      payload: 'items_binned',
    );
  }

  /// Shows a notification for items ready for review.
  Future<void> showReminderNotification(int count) async {
    await init();
    await _flutterLocalNotificationsPlugin.show(
      id: 2,
      title: 'Review Temporary Items',
      body: '$count items are ready to review in your Temporary section.',
      notificationDetails: _getNotificationDetails(),
      payload: 'items_review',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
