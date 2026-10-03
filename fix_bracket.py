with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

# Let's see how many brackets are actually needed.
import re
match = re.search(r'error: \(err, stack\) => Center\([\s\S]*?child: Text\(\'Failed to load items:\\n\$err\'\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?\),', content)
if match:
    # Just fix the ending before floatingActionButton
    content = re.sub(r'\),\s*\),\s*\),\s*floatingActionButton:', '),\n        ),\n      ),\n      floatingActionButton:', content)
    
with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
