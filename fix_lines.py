with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "child: Text('Failed to load items:" in line:
        lines[i] = "                  child: Text('Failed to load items:\\n$err'),\n"
    if "$err')," in line and "child: Text" not in line:
        lines[i] = ""

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.writelines(lines)
