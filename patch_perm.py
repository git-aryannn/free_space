with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

import re

# 1. State changes for _PermanentScreenState
target_state = r'''class _PermanentScreenState extends ConsumerState<PermanentScreen> {
  final TextEditingController _searchController = TextEditingController\(\);
  final FocusNode _searchFocusNode = FocusNode\(\);
  String _searchQuery = '';
  bool _isSearchExpanded = false;
  bool _isScanning = false;
  bool _selectingAll = false;
  bool _allItemsSelected = false;
  bool _selectionMode = false;
  bool _showPermanentCount = false;
  Timer\? _permanentCountTimer;
  final Set<int> _selectedIds = \{\};
  final Map<int, TrackedItemModel> _selectedItems = \{\};'''

replacement_state = r'''class _PermanentScreenState extends ConsumerState<PermanentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearchExpanded = false;
  bool _isScanning = false;
  bool _selectingAll = false;
  bool _allItemsSelected = false;
  bool _selectionMode = false;
  bool _showPermanentCount = false;
  Timer? _permanentCountTimer;
  final Set<int> _selectedIds = {};
  final Map<int, TrackedItemModel> _selectedItems = {};
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
  }'''

content = re.sub(target_state, replacement_state, content)

# 2. Add dispose for _scrollController
content = content.replace("    _searchController.dispose();\n    super.dispose();\n  }", "    _searchController.dispose();\n    _scrollController.dispose();\n    super.dispose();\n  }")

# 3. Replace Scaffold -> NestedScrollView
target_scaffold = r'''    return Scaffold\(
      appBar: AppBar\(
        toolbarHeight: 68,
        title: Column\('''

replacement_scaffold = r'''    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            toolbarHeight: 68,
            floating: true,
            snap: true,
            title: Column('''

content = re.sub(target_scaffold, replacement_scaffold, content)

# 4. Replace End of AppBar and Body
target_body = r'''          Center\(
            child: Padding\(
              padding: const EdgeInsets\.only\(right: 16\.0\),
              child: Tooltip\(
                message:
                    'This folder contains \$\{permCountAsync\.valueOrNull \?\? 0\} items on your device',
                showDuration: const Duration\(seconds: 3\),
                child: IconButton\(
                  onPressed: \(\) => _revealPermanentCount\(
                    permCountAsync\.valueOrNull \?\? 0,
                  \),
                  icon: const Icon\(Icons\.lock_outline\),
                \),
              \),
            \),
          \),
        \],
      \),
      body: Column\('''

replacement_body = r'''          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Tooltip(
                message:
                    'This folder contains ${permCountAsync.valueOrNull ?? 0} items on your device',
                showDuration: const Duration(seconds: 3),
                child: IconButton(
                  onPressed: () => _revealPermanentCount(
                    permCountAsync.valueOrNull ?? 0,
                  ),
                  icon: const Icon(Icons.lock_outline),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _isSearchExpanded 
                      ? CrossFadeState.showSecond 
                      : CrossFadeState.showFirst,
                  firstChild: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              _isSearchExpanded = true;
                            });
                            Future.delayed(const Duration(milliseconds: 100), () {
                              _searchFocusNode.requestFocus();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChipWidget(
                          label: 'All',
                          value: ItemFilter.all,
                          currentValue: currentFilter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChipWidget(
                          label: 'Media',
                          value: ItemFilter.media,
                          currentValue: currentFilter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChipWidget(
                          label: 'Files',
                          value: ItemFilter.files,
                          currentValue: currentFilter,
                        ),
                        const SizedBox(width: 8),
                        _FilterChipWidget(
                          label: 'Apps',
                          value: ItemFilter.apps,
                          currentValue: currentFilter,
                        ),
                      ],
                    ),
                  ),
                  secondChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search permanent items...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _isSearchExpanded = false;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    ],
    body: Column('''

content = re.sub(target_body, replacement_body, content)

# Remove the Filter Chips and Divider from body: Column
# They are from line 290 to 372
target_remove_filter = r'''          Padding\(
            padding: const EdgeInsets\.symmetric\(horizontal: 8\.0, vertical: 8\.0\),
            child: AnimatedCrossFade\(
              duration: const Duration\(milliseconds: 200\),
              crossFadeState: _isSearchExpanded 
                  \? CrossFadeState\.showSecond 
                  : CrossFadeState\.showFirst,
              firstChild: SingleChildScrollView\(
                scrollDirection: Axis\.horizontal,
                padding: const EdgeInsets\.symmetric\(horizontal: 8\),
                child: Row\(
                  children: \[
                    IconButton\(
                      icon: const Icon\(Icons\.search\),
                      onPressed: \(\) \{
                        setState\(\(\) \{
                          _isSearchExpanded = true;
                        \}\);
                        Future\.delayed\(const Duration\(milliseconds: 100\), \(\) \{
                          _searchFocusNode\.requestFocus\(\);
                        \}\);
                      \},
                    \),
                    const SizedBox\(width: 8\),
                    _FilterChipWidget\(
                      label: 'All',
                      value: ItemFilter\.all,
                      currentValue: currentFilter,
                    \),
                    const SizedBox\(width: 8\),
                    _FilterChipWidget\(
                      label: 'Media',
                      value: ItemFilter\.media,
                      currentValue: currentFilter,
                    \),
                    const SizedBox\(width: 8\),
                    _FilterChipWidget\(
                      label: 'Files',
                      value: ItemFilter\.files,
                      currentValue: currentFilter,
                    \),
                    const SizedBox\(width: 8\),
                    _FilterChipWidget\(
                      label: 'Apps',
                      value: ItemFilter\.apps,
                      currentValue: currentFilter,
                    \),
                  \],
                \),
              \),
              secondChild: Padding\(
                padding: const EdgeInsets\.symmetric\(horizontal: 8\.0\),
                child: TextField\(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration\(
                    hintText: 'Search permanent items\.\.\.',
                    prefixIcon: const Icon\(Icons\.search\),
                    border: OutlineInputBorder\(
                      borderRadius: BorderRadius\.circular\(24\),
                    \),
                    contentPadding: const EdgeInsets\.symmetric\(vertical: 0, horizontal: 16\),
                    suffixIcon: IconButton\(
                      icon: const Icon\(Icons\.close\),
                      onPressed: \(\) \{
                        _searchController\.clear\(\);
                        setState\(\(\) \{
                          _searchQuery = '';
                          _isSearchExpanded = false;
                        \}\);
                      \},
                    \),
                  \),
                  onChanged: \(value\) \{
                    setState\(\(\) \{
                      _searchQuery = value;
                    \}\);
                  \},
                \),
              \),
            \),
          \),
          const Divider\(height: 1\),'''
          
content = re.sub(target_remove_filter, "", content)

# 5. Fix end brackets for NestedScrollView and Scaffold
target_end_scaffold = r'''          \),
        \],
      \),
      floatingActionButton: FloatingActionButton\('''

replacement_end_scaffold = r'''          ),
        ],
      ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showBackToTop) ...[
            FloatingActionButton.small(
              heroTag: 'perm_to_top',
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
          FloatingActionButton('''

content = re.sub(target_end_scaffold, replacement_end_scaffold, content)

# Also need to close the children of Column for floatingActionButton
content = content.replace("        child: Icon(_selectionMode ? Icons.close : Icons.checklist),\n      ),", "        child: Icon(_selectionMode ? Icons.close : Icons.checklist),\n      ),\n        ],\n      ),")


# 6. Fix _PermanentItemsPagedList to use PrimaryScrollController
target_paged_list_state = r'''class _PermanentItemsPagedListState
    extends ConsumerState<_PermanentItemsPagedList> {
  final ScrollController _scrollController = ScrollController\(\);
  int _loadedPageCount = 1;
  bool _loadingMore = false;
  bool _hasMore = false;

  @override
  void initState\(\) \{
    super\.initState\(\);
    _scrollController\.addListener\(_maybeLoadNextPage\);
  \}

  @override
  void dispose\(\) \{
    _scrollController
      \.\.removeListener\(_maybeLoadNextPage\)
      \.\.dispose\(\);
    super\.dispose\(\);
  \}'''

replacement_paged_list_state = r'''class _PermanentItemsPagedListState
    extends ConsumerState<_PermanentItemsPagedList> {
  ScrollController? _scrollController;
  int _loadedPageCount = 1;
  bool _loadingMore = false;
  bool _hasMore = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController?.removeListener(_maybeLoadNextPage);
    _scrollController = PrimaryScrollController.maybeOf(context);
    _scrollController?.addListener(_maybeLoadNextPage);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_maybeLoadNextPage);
    super.dispose();
  }'''

content = re.sub(target_paged_list_state, replacement_paged_list_state, content)

# Update _scrollController usage in _maybeLoadNextPage
content = content.replace("!_scrollController.hasClients ||", "!(_scrollController?.hasClients ?? false) ||")
content = content.replace("_scrollController.position.extentAfter > 500", "(_scrollController?.position.extentAfter ?? 0) > 500")

# Update ListView.builder controller
# Just remove it since it defaults to PrimaryScrollController
content = content.replace("      controller: _scrollController,\n      padding: const EdgeInsets.all(8),", "      padding: const EdgeInsets.all(8),")

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
