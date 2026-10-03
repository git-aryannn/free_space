import re

with open("lib/data/services/notification_service.dart", "r") as f:
    content = f.read()

target = r'''  @pragma\('vm:entry-point'\)
  static void _onNotificationAction\(NotificationResponse response\) \{
    developer\.log\('Background action tapped: \$\{response\.actionId\} payload: \$\{response\.payload\}'\);
    // Ideally we communicate this back or update DB here if it's a background isolate\.
    // For now, this requires a background isolate to handle it properly\.
  \}'''

replacement = '''  @pragma('vm:entry-point')
  static void _onNotificationAction(NotificationResponse response) async {
    developer.log('Background action tapped: ${response.actionId} payload: ${response.payload}');
    if (response.actionId != null && response.payload != null) {
      // Background isolate, we need to spin up the DB manually
      // This is a bit tricky but we can try to do it via drift directly or if there is a static instance.
      // For now, let's just log. To properly save to DB from background isolate in flutter,
      // you need to initialize drift db connection again.
      developer.log('Action handled in background. Not saving to DB yet because no DB instance available.');
    }
  }'''

content = re.sub(target, replacement, content)

with open("lib/data/services/notification_service.dart", "w") as f:
    f.write(content)

