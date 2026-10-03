import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

content = content.replace("networkType: NetworkType.not_required,", "networkType: NetworkType.connected,")

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)

with open("lib/data/services/background_live_service.dart", "r") as f:
    bg_content = f.read()

target = r'''      final newItems = await syncService\.performSync\(\);
      if \(newItems\.isNotEmpty\) \{
        // Send notification for each or just one summary
        final inboxItems = await itemRepo\.getAllItems\(\);
        if \(inboxItems\.length > lastInboxCount\) \{
          lastInboxCount = inboxItems\.length;
          
          if \(newItems\.length == 1\) \{
             await notificationService\.showNewItemNotification\(
                newItems\.first\.name, 
                newItems\.first\.path, 
                newItems\.first\.sizeBytes
             \);
          \} else \{
             await notificationService\.showReminderNotification\(inboxItems\.length\);
          \}
        \}
      \}'''

replacement = r'''      final beforeItems = await itemRepo.getAllItems();
      final beforeCount = beforeItems.length;
      await syncService.performSync();
      final afterItems = await itemRepo.getAllItems();
      final afterCount = afterItems.length;
      
      if (afterCount > beforeCount) {
        lastInboxCount = afterCount;
        final newCount = afterCount - beforeCount;
        if (newCount == 1) {
           final newItem = afterItems.last;
           await notificationService.showNewItemNotification(
              newItem.name, 
              newItem.path, 
              newItem.sizeBytes
           );
        } else {
           await notificationService.showReminderNotification(newCount);
        }
      }'''

bg_content = re.sub(target, replacement, bg_content)

target2 = r'''      final newItems = await syncService\.performSync\(\);
      if \(newItems\.isNotEmpty\) \{
        if \(newItems\.length == 1\) \{
           await notificationService\.showNewItemNotification\(
              newItems\.first\.name, 
              newItems\.first\.path, 
              newItems\.first\.sizeBytes
           \);
        \} else \{
           await notificationService\.showReminderNotification\(newItems\.length\);
        \}
      \}'''

replacement2 = r'''      final beforeItems = await itemRepo.getAllItems();
      final beforeCount = beforeItems.length;
      await syncService.performSync();
      final afterItems = await itemRepo.getAllItems();
      final afterCount = afterItems.length;
      
      if (afterCount > beforeCount) {
        final newCount = afterCount - beforeCount;
        if (newCount == 1) {
           final newItem = afterItems.last;
           await notificationService.showNewItemNotification(
              newItem.name, 
              newItem.path, 
              newItem.sizeBytes
           );
        } else {
           await notificationService.showReminderNotification(newCount);
        }
      }'''

bg_content = re.sub(target2, replacement2, bg_content)

with open("lib/data/services/background_live_service.dart", "w") as f:
    f.write(bg_content)
