with open("lib/main.dart", "r") as f:
    lines = f.readlines()

out = []
skip = False
for line in lines:
    if "import 'package:flutter/services.dart';" in line:
        continue
    if "try {" in line and "final channel = MethodChannel" in lines[lines.index(line)+1]:
        skip = True
    if skip and "}" in line and "DEBUG TEST ERROR" in lines[lines.index(line)-1]:
        skip = False
        continue
    if not skip:
        out.append(line)

with open("lib/main.dart", "w") as f:
    f.writelines(out)
