with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if line.strip() == "child: RefreshIndicator(":
        # Remove the 'child: ' part since it's the body of NestedScrollView
        new_lines.append(line.replace("child: ", ""))
    elif line.strip() == "child: Text('Failed to load items:":
        # The multiline string
        new_lines.append("                  child: Text('Failed to load items:\\n$err'),\n")
    elif "$err')," in line:
        pass # skip
    else:
        new_lines.append(line)

content = "".join(new_lines)

# Fix State variables
if "_scrollController" not in content:
    old_vars = "  bool _selectionMode = false;\n  final Set<int> _selectedIds = {};\n"
    new_vars = """  bool _selectionMode = false;
  final Set<int> _selectedIds = {};
  
  late final ScrollController _scrollController;
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 200 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
"""
    content = content.replace(old_vars, new_vars)

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
