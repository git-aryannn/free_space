import re

with open("lib/presentation/screens/home/dashboard_screen.dart", "r") as f:
    content = f.read()

if "package:go_router/go_router.dart" not in content:
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:go_router/go_router.dart';"
    )
    with open("lib/presentation/screens/home/dashboard_screen.dart", "w") as f:
        f.write(content)
