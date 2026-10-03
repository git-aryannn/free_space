import re

with open("lib/data/services/notification_service.dart", "r") as f:
    content = f.read()

# fix initialize
content = re.sub(
    r'''await _flutterLocalNotificationsPlugin\.initialize\(\s*initializationSettings,\s*onDidReceiveNotificationResponse: _onNotificationTapped,\s*onDidReceiveBackgroundNotificationResponse: _onNotificationAction,\s*\);''',
    '''await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onNotificationAction,
    );''',
    content
)

# fix show 1
content = re.sub(
    r'''await _flutterLocalNotificationsPlugin\.show\(\s*path\.hashCode, // Unique ID per file\s*'New Download Detected',\s*'\$itemName \(\$sizeMb MB\)',\s*_getNewItemNotificationDetails\(path\),\s*payload: path,\s*\);''',
    '''await _flutterLocalNotificationsPlugin.show(
      id: path.hashCode, // Unique ID per file
      title: 'New Download Detected',
      body: '$itemName ($sizeMb MB)',
      notificationDetails: _getNewItemNotificationDetails(path),
      payload: path,
    );''',
    content
)

# fix show 2
content = re.sub(
    r'''await _flutterLocalNotificationsPlugin\.show\(\s*1,\s*'Some items moved to Bin',\s*message,\s*_getNotificationDetails\(\),\s*payload: 'items_binned',\s*\);''',
    '''await _flutterLocalNotificationsPlugin.show(
      id: 1,
      title: 'Some items moved to Bin',
      body: message,
      notificationDetails: _getNotificationDetails(),
      payload: 'items_binned',
    );''',
    content
)

# fix show 3
content = re.sub(
    r'''await _flutterLocalNotificationsPlugin\.show\(\s*2,\s*'Review Temporary Items',\s*'\$count items are ready to review in your Temporary section\.',\s*_getNotificationDetails\(\),\s*payload: 'items_review',\s*\);''',
    '''await _flutterLocalNotificationsPlugin.show(
      id: 2,
      title: 'Review Temporary Items',
      body: '$count items are ready to review in your Temporary section.',
      notificationDetails: _getNotificationDetails(),
      payload: 'items_review',
    );''',
    content
)

# fix cancel
content = content.replace("await _flutterLocalNotificationsPlugin.cancel(id);", "await _flutterLocalNotificationsPlugin.cancel(id: id);")

with open("lib/data/services/notification_service.dart", "w") as f:
    f.write(content)
