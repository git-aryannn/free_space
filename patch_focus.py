import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

content = content.replace("final TextEditingController _searchController = TextEditingController();", "final TextEditingController _searchController = TextEditingController();\n  final FocusNode _searchFocusNode = FocusNode();")

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)

