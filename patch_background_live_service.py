import re

with open("lib/data/services/background_live_service.dart", "r") as f:
    content = f.read()

# Replace onStart setup
old_onstart = r'''  // Initialize DB and Repos in the background isolate
  final db = AppDatabase\(\);
  final itemRepo = ItemRepository\(db\);
  final settingsRepo = SettingsRepository\(db.settingsDao\);
  final syncService = SyncService\(itemRepo, settingsRepo\);
  final notificationService = NotificationService\(\);
  await notificationService.init\(\);'''

new_onstart = r'''  // Initialize via Riverpod container in background isolate
  final container = ProviderContainer();
  final itemRepo = container.read(itemRepositoryProvider);
  final settingsRepo = container.read(settingsRepositoryProvider);
  final syncService = container.read(syncServiceProvider);
  final notificationService = NotificationService();
  await notificationService.init();'''

content = re.sub(old_onstart, new_onstart, content)

# Replace WorkManager setup
old_work = r'''    final db = AppDatabase\(\);
    final itemRepo = ItemRepository\(db\);
    final settingsRepo = SettingsRepository\(db.settingsDao\);
    final syncService = SyncService\(itemRepo, settingsRepo\);
    final notificationService = NotificationService\(\);
    await notificationService.init\(\);'''

content = re.sub(old_work, new_onstart, content)

# Fix getInboxItems
content = content.replace("final inboxItems = await itemRepo.getInboxItems();", "final inboxItems = await itemRepo.getAllItems();")

# Fix NetworkType.not_required
content = content.replace("networkType: NetworkType.not_required,", "")

with open("lib/data/services/background_live_service.dart", "w") as f:
    f.write(content)
