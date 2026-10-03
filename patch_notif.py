import re

with open("lib/data/services/notification_service.dart", "r") as f:
    content = f.read()

target = r'''  void _onNotificationTapped\(NotificationResponse response\) \{
    developer\.log\('Notification tapped with payload: \$\{response\.payload\}'\);
    // Handle navigation or action based on payload
  \}

  NotificationDetails _getNotificationDetails\(\) \{
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails\(
      'free_space_channel',
      'Free Space Notifications',
      importance: Importance\.max,
      priority: Priority\.high,
    \);
    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails\(\);
    return const NotificationDetails\(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
      macOS: darwinPlatformChannelSpecifics,
    \);
  \}

  /// Shows a notification when a new item is detected\.
  Future<void> showNewItemNotification\(String itemName\) async \{
    await init\(\);
    await _flutterLocalNotificationsPlugin\.show\(
      0,
      'New Item Detected',
      'New item detected: \$itemName\. Tap to categorize\.',
      _getNotificationDetails\(\),
      payload: 'item_detected',
    \);
  \}'''

replacement = '''  final Function(String actionId, String payload)? onActionTapped;

  NotificationService({this.onActionTapped});

  @pragma('vm:entry-point')
  static void _onNotificationAction(NotificationResponse response) {
    developer.log('Background action tapped: ${response.actionId} payload: ${response.payload}');
    // Ideally we communicate this back or update DB here if it's a background isolate.
    // For now, this requires a background isolate to handle it properly.
  }

  void _onNotificationTapped(NotificationResponse response) {
    developer.log('Notification tapped with payload: ${response.payload} action: ${response.actionId}');
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
  Future<void> showNewItemNotification(String itemName, String path, int sizeBytes) async {
    await init();
    
    // Format size
    final sizeMb = (sizeBytes / (1024 * 1024)).toStringAsFixed(1);
    
    await _flutterLocalNotificationsPlugin.show(
      path.hashCode, // Unique ID per file
      'New Download Detected',
      '$itemName ($sizeMb MB)',
      _getNewItemNotificationDetails(path),
      payload: path,
    );
  }'''

content = re.sub(target, replacement, content)

# we also need to pass the onActionTapped when creating it in Provider.
# Let's just create a basic method or provide a global hook.

with open("lib/data/services/notification_service.dart", "w") as f:
    f.write(content)

