import re

with open("lib/data/repositories/settings_repository.dart", "r") as f:
    content = f.read()

# Add key
target_keys = r'''  static const String _keyDetectionMode = 'detection_mode';'''
replacement_keys = r'''  static const String _keyDetectionMode = 'detection_mode';
  static const String _keyLastSyncTime = 'last_sync_time';'''

content = re.sub(target_keys, replacement_keys, content)

# Add getters and setters
target_methods = r'''  Future<void> setDetectionMode\(DetectionMode mode\) async \{
    await _dao\.saveSetting\(_keyDetectionMode, mode\.name\);
  \}'''

replacement_methods = r'''  Future<void> setDetectionMode(DetectionMode mode) async {
    await _dao.saveSetting(_keyDetectionMode, mode.name);
  }

  Future<DateTime?> getLastSyncTime() async {
    final value = await _dao.getSetting(_keyLastSyncTime);
    if (value != null) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    await _dao.saveSetting(_keyLastSyncTime, time.toIso8601String());
  }'''

content = re.sub(target_methods, replacement_methods, content)

with open("lib/data/repositories/settings_repository.dart", "w") as f:
    f.write(content)

