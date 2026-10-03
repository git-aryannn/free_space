import re

with open("lib/data/services/notification_service.dart", "r") as f:
    content = f.read()

replacement = '''
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}'''

content = re.sub(r'\}$', replacement, content)

with open("lib/data/services/notification_service.dart", "w") as f:
    f.write(content)

