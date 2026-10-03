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

# 2. Replace Scaffold
target_scaffold = r'''    return Scaffold\(
      floatingActionButton: FloatingActionButton\(
        heroTag: null,
        onPressed: \(\) => setState\(\(\) \{
          _selectionMode = !_selectionMode;
          _selectedIds\.clear\(\);
          _selectedSystemTrashPaths\.clear\(\);
        \}\),
        tooltip: _selectionMode \? 'Exit selection' : 'Select items',
        child: Icon\(_selectionMode \? Icons\.close : Icons\.checklist\),
      \),
      appBar: AppBar\('''

replacement_scaffold = r'''    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showBackToTop) ...[
            FloatingActionButton.small(
              heroTag: 'bin_to_top',
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              tooltip: 'Scroll to top',
              child: const Icon(Icons.keyboard_arrow_up),
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton(
            heroTag: 'bin_select',
            onPressed: () => setState(() {
              _selectionMode = !_selectionMode;
              _selectedIds.clear();
              _selectedSystemTrashPaths.clear();
            }),
            tooltip: _selectionMode ? 'Exit selection' : 'Select items',
            child: Icon(_selectionMode ? Icons.close : Icons.checklist),
          ),
        ],
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Bin'),'''

content = re.sub(target_scaffold, replacement_scaffold, content)

# 3. Fix the end of AppBar
target_end_appbar = r'''          if \(!_selectionMode\)
            IconButton\(
              icon: const Icon\(Icons\.delete_sweep\),
              tooltip: 'Empty Bin',
              onPressed: trackedBinItems\.isEmpty &&
                      visibleSystemTrashItems\.isEmpty
                  \? null
                  : \(\) => _confirmEmptyBin\(context, ref\),
            \),
        \],
      \),
      body: RefreshIndicator\('''

replacement_end_appbar = r'''          if (!_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Empty Bin',
              onPressed: trackedBinItems.isEmpty &&
                      visibleSystemTrashItems.isEmpty
                  ? null
                  : () => _confirmEmptyBin(context, ref),
            ),
        ],
      ),
      ],
      body: RefreshIndicator('''

content = re.sub(target_end_appbar, replacement_end_appbar, content)

# 4. Fix NestedScrollView closing bracket
# Wait, `RefreshIndicator` goes to the very end of `build`.
# The very end of `build` has:
target_end = r'''        loading: \(\) => const Center\(child: CircularProgressIndicator\(\)\),
        error: \(err, stack\) => Center\(child: Text\('Error: \$err'\)\),
      \),
    \);
  \}'''

replacement_end = r'''        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      ),
    );
  }'''

content = re.sub(target_end, replacement_end, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
