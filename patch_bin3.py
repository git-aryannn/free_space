with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

import re

# 1. State changes
target_state = r'''class _BinScreenState extends ConsumerState<BinScreen> {
  bool _selectionMode = false;
  bool _requestingTrashAccess = false;
  final Set<int> _selectedIds = \{\};
  final Set<String> _selectedSystemTrashPaths = \{\};'''

replacement_state = r'''class _BinScreenState extends ConsumerState<BinScreen> {
  bool _selectionMode = false;
  bool _requestingTrashAccess = false;
  final Set<int> _selectedIds = {};
  final Set<String> _selectedSystemTrashPaths = {};

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
  }'''

content = re.sub(target_state, replacement_state, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
