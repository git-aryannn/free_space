import re

with open("lib/data/services/sync_service.dart", "r") as f:
    content = f.read()

target = r'''  Future<void> performSync\(\) async \{
    final settingsRepo = ref\.read\(settingsRepositoryProvider\);
    final itemRepo = ref\.read\(itemRepositoryProvider\);
    final nativeService = ref\.read\(nativePlatformServiceProvider\);

    final mode = await settingsRepo\.getDetectionMode\(\);
    if \(mode != DetectionMode\.smartSync\) \{
      return; // Only sync in Smart Sync mode
    \}'''

replacement = r'''  Future<void> performSync({bool force = false}) async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final itemRepo = ref.read(itemRepositoryProvider);
    final nativeService = ref.read(nativePlatformServiceProvider);

    if (!force) {
      final mode = await settingsRepo.getDetectionMode();
      if (mode != DetectionMode.smartSync) {
        return; // Only sync on open in Smart Sync mode
      }
    }'''

content = re.sub(target, replacement, content)

with open("lib/data/services/sync_service.dart", "w") as f:
    f.write(content)
