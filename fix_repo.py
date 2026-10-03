import re

with open("lib/data/repositories/settings_repository.dart", "r") as f:
    content = f.read()

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
    await _dao.setSetting(_keyDetectionMode, mode.name);
  }

  Future<DateTime?> getLastSyncTime() async {
    final value = await _dao.getSetting(_keyLastSyncTime);
    if (value != null) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    await _dao.setSetting(_keyLastSyncTime, time.toIso8601String());
  }
"""

content = content.replace(
    "  Future<void> setInactivityDays(int days) async {\n    await _dao.setSetting(_keyInactivityDays, days.toString());\n  }",
    "  Future<void> setInactivityDays(int days) async {\n    await _dao.setSetting(_keyInactivityDays, days.toString());\n  }\n" + methods
)

with open("lib/data/repositories/settings_repository.dart", "w") as f:
    f.write(content)

