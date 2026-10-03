import re

with open("lib/data/services/notification_service.dart", "r") as f:
    content = f.read()

target = r'''    await _flutterLocalNotificationsPlugin\.initialize\(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    \);'''

replacement = '''    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onNotificationAction,
    );'''

content = re.sub(target, replacement, content)

with open("lib/data/services/notification_service.dart", "w") as f:
    f.write(content)

