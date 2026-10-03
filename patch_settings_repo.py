import re

with open("lib/data/repositories/settings_repository.dart", "r") as f:
    content = f.read()

import_str = "import 'package:free_space/data/models/tracked_item_model.dart';\nimport 'dart:convert';\n"
if "dart:convert" not in content:
    content = content.replace("import 'package:free_space/data/database/app_database.dart';", import_str + "import 'package:free_space/data/database/app_database.dart';")

new_methods = r'''
  static const String _keyInboxItems = 'inbox_items';

  Future<List<TrackedItemModel>> getInboxItems() async {
    final value = await _dao.getSetting(_keyInboxItems);
    if (value != null && value.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(value);
        return jsonList.map((e) => TrackedItemModel.fromJson(e)).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> setInboxItems(List<TrackedItemModel> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    await _dao.setSetting(_keyInboxItems, jsonEncode(jsonList));
  }
'''

content = content.replace("  Future<void> setLastSyncTime(DateTime time) async {\n    await _dao.setSetting(_keyLastSyncTime, time.toIso8601String());\n  }", "  Future<void> setLastSyncTime(DateTime time) async {\n    await _dao.setSetting(_keyLastSyncTime, time.toIso8601String());\n  }\n" + new_methods)

with open("lib/data/repositories/settings_repository.dart", "w") as f:
    f.write(content)
