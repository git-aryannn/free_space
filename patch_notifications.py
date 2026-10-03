import re

with open("lib/data/services/notification_service.dart", "r") as f:
    content = f.read()

# Fix initialize
content = content.replace(
    'await _flutterLocalNotificationsPlugin.initialize(\n      initializationSettings,\n      onDidReceiveNotificationResponse: _onNotificationTapped,\n      onDidReceiveBackgroundNotificationResponse: _onNotificationAction,\n    );',
    'await _flutterLocalNotificationsPlugin.initialize(\n      initializationSettings,\n      onDidReceiveNotificationResponse: _onNotificationTapped,\n      onDidReceiveBackgroundNotificationResponse: _onNotificationAction,\n    );'
)
# Actually initialize in v17 takes initializationSettings as positional first arg. Wait!
# The error was: Too many positional arguments: 0 allowed, but 1 found.
# Let's change initialize to named argument? No, the documentation says positional.
# But just in case, let's try `initializationSettings: initializationSettings`.

# Let's look at the flutter_local_notifications code I grepped.
# Future<bool?> initialize(InitializationSettings initializationSettings, { ... })
# It IS positional!!! Why did it say 0 allowed?!
