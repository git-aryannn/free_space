import re

with open("lib/main.dart", "r") as f:
    content = f.read()

import_statement = "import 'package:free_space/data/services/background_live_service.dart';\n"
if "background_live_service.dart" not in content:
    content = import_statement + content

main_init = r'''void main\(\) async \{
  WidgetsFlutterBinding.ensureInitialized\(\);
  await initializeBackgroundService\(\);'''

content = re.sub(r'''void main\(\) \{
  WidgetsFlutterBinding\.ensureInitialized\(\);''', main_init, content)

with open("lib/main.dart", "w") as f:
    f.write(content)
