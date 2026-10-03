with open("lib/data/services/background_live_service.dart", "r") as f:
    content = f.read()

imports = """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/presentation/providers/items_provider.dart';
import 'package:free_space/presentation/providers/database_provider.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';
"""

if "package:flutter_riverpod" not in content:
    content = imports + content
    with open("lib/data/services/background_live_service.dart", "w") as f:
        f.write(content)
