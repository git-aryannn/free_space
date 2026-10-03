import re

with open("lib/data/services/sync_service.dart", "r") as f:
    content = f.read()

if "import 'package:free_space/data/providers/platform_provider.dart';" not in content:
    content = "import 'package:free_space/presentation/providers/platform_provider.dart';\n" + content
    
if "package:free_space/presentation/providers/platform_provider.dart" not in content:
    # Actually wait, where is nativePlatformServiceProvider?
    pass

with open("lib/data/services/sync_service.dart", "w") as f:
    f.write(content)

