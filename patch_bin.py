with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

import re

# 1. State changes
target_state = r'''class _BinScreenState extends ConsumerState<BinScreen> {
  bool _selectionMode = false;
  final Set<int> _selectedIds = \{\};
  final Set<String> _selectedSystemTrashPaths = \{\};
  bool _requestingTrashAccess = false;'''

replacement_state = r'''class _BinScreenState extends ConsumerState<BinScreen> {
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};
  final Set<String> _selectedSystemTrashPaths = {};
  bool _requestingTrashAccess = false;

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

# 2. Replace Scaffold -> NestedScrollView
target_scaffold = r'''  @override
  Widget build\(BuildContext context\) \{
    final binItemsAsync = ref\.watch\(binnedItemsProvider\);
    final systemTrashAsync = ref\.watch\(systemTrashItemsProvider\);
    final trackedBinItems = binItemsAsync\.valueOrNull \?\? const \[\];
    final trackedTrashPaths = trackedBinItems
        \.map\(\(item\) => item\.systemTrashPath\)
        \.whereType<String>\(\)
        \.toSet\(\);
    final systemTrashItems = \(systemTrashAsync\.valueOrNull \?\? const \[\]\)
        \.where\(\(item\) => !trackedTrashPaths\.contains\(item\.trashPath\)\)
        \.toList\(\);

    final allVisibleSelected =
        trackedBinItems\.isNotEmpty \|\| systemTrashItems\.isNotEmpty
            \? trackedBinItems\.every\(\(item\) => _selectedIds\.contains\(item\.id\)\) &&
                systemTrashItems\.every\(\(item\) =>
                    _selectedSystemTrashPaths\.contains\(item\.trashPath\)\)
            : false;

    return Scaffold\(
      appBar: AppBar\('''

replacement_scaffold = r'''  @override
  Widget build(BuildContext context) {
    final binItemsAsync = ref.watch(binnedItemsProvider);
    final systemTrashAsync = ref.watch(systemTrashItemsProvider);
    final trackedBinItems = binItemsAsync.valueOrNull ?? const [];
    final trackedTrashPaths = trackedBinItems
        .map((item) => item.systemTrashPath)
        .whereType<String>()
        .toSet();
    final systemTrashItems = (systemTrashAsync.valueOrNull ?? const [])
        .where((item) => !trackedTrashPaths.contains(item.trashPath))
        .toList();

    final allVisibleSelected =
        trackedBinItems.isNotEmpty || systemTrashItems.isNotEmpty
            ? trackedBinItems.every((item) => _selectedIds.contains(item.id)) &&
                systemTrashItems.every((item) =>
                    _selectedSystemTrashPaths.contains(item.trashPath))
            : false;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,'''

content = re.sub(target_scaffold, replacement_scaffold, content)

# 3. Replace end of AppBar and body
target_body = r'''            if \(!_selectionMode\)
              IconButton\(
                icon: const Icon\(Icons\.delete_sweep\),
                tooltip: 'Empty Bin',
                onPressed:
                    trackedBinItems\.isEmpty && systemTrashItems\.isEmpty
                        \? null
                        : \(\) => _confirmEmptyBin\(context, ref\),
              \),
          \],
        \),
      \],
      body: RefreshIndicator\('''

replacement_body = r'''            if (!_selectionMode)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Empty Bin',
                onPressed:
                    trackedBinItems.isEmpty && systemTrashItems.isEmpty
                        ? null
                        : () => _confirmEmptyBin(context, ref),
              ),
          ],
        ),
      ],
      body: RefreshIndicator('''

# WAIT, BinScreen has:
#       appBar: AppBar(
#         title: const Text('Bin'),
#         actions: [
# Ah wait, I replaced Scaffold -> NestedScrollView but it has `actions:`.
# Let's see how I matched it. I should look at BinScreen's `appBar:` part first.
