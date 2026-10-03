with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

import re

# Fix state variables
content = re.sub(r"  bool _selectionMode = false;\n  final Set<int> _selectedIds = \{\};", r'''  bool _selectionMode = false;
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
  }''', content)

# Fix the hanging brackets at the end
# The current brackets around RefreshIndicator are messed up.
# Let's see how they look.
