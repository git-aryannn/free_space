import re

# 1. Fix Inbox Provider
with open("lib/presentation/providers/inbox_provider.dart", "r") as f:
    content = f.read()
content = content.replace("package:free_space/data/models/tracked_item.dart", "package:free_space/data/models/tracked_item_model.dart")
with open("lib/presentation/providers/inbox_provider.dart", "w") as f:
    f.write(content)

# 2. Fix Sync Service
with open("lib/data/services/sync_service.dart", "r") as f:
    content = f.read()
content = content.replace("package:free_space/data/models/tracked_item.dart", "package:free_space/data/models/tracked_item_model.dart\nimport 'package:free_space/data/models/item_enums.dart';")
with open("lib/data/services/sync_service.dart", "w") as f:
    f.write(content)

# 3. Fix Settings Repository
with open("lib/data/repositories/settings_repository.dart", "r") as f:
    content = f.read()

# Make sure the enum is there
if "enum DetectionMode" not in content:
    content = "enum DetectionMode { smartSync, liveMonitoring }\n\n" + content

# Make sure keys are there
if "_keyDetectionMode" not in content:
    content = content.replace(
        "static const String _keyInactivityDays = 'inactivity_days';",
        "static const String _keyInactivityDays = 'inactivity_days';\n  static const String _keyDetectionMode = 'detection_mode';\n  static const String _keyLastSyncTime = 'last_sync_time';"
    )

if "getDetectionMode" not in content:
    methods = """
  Future<DetectionMode> getDetectionMode() async {
    final value = await _dao.getSetting(_keyDetectionMode);
    if (value != null) {
      return DetectionMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => DetectionMode.smartSync,
      );
    }
    return DetectionMode.smartSync;
  }

  Future<void> setDetectionMode(DetectionMode mode) async {
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
  }
"""
    content = content.replace(
        "  Future<void> setInactivityDays(int days) async {\n    await _dao.saveSetting(_keyInactivityDays, days.toString());\n  }",
        "  Future<void> setInactivityDays(int days) async {\n    await _dao.saveSetting(_keyInactivityDays, days.toString());\n  }\n" + methods
    )

with open("lib/data/repositories/settings_repository.dart", "w") as f:
    f.write(content)

