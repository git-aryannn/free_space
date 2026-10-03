import re

with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

# Add ScrollController and showFab state
if "ScrollController _scrollController = ScrollController();" not in content:
    init_state = r'''  Set<int> _selectedIds = {};
  bool _selectionMode = false;

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
    content = content.replace("  Set<int> _selectedIds = {};\n  bool _selectionMode = false;", init_state)

# Replace AppBar and body with NestedScrollView
target_scaffold = r'''    return Scaffold\(
      appBar: AppBar\(
        title: const Text\('Temporary Items'\),
        actions: \[
          if \(_selectionMode && _selectedIds\.isNotEmpty\)
            PopupMenuButton<ItemCategory>\(
              icon: const Icon\(Icons\.drive_file_move\),
              onSelected: _moveSelected,
              itemBuilder: \(context\) => const \[
                PopupMenuItem\(
                  value: ItemCategory\.permanent,
                  child: Text\('Move to Permanent'\),
                \),
                PopupMenuItem\(
                  value: ItemCategory\.binned,
                  child: Text\('Move to Bin'\),
                \),
              \],
            \),
          if \(_selectionMode\)
            TextButton\(
              onPressed: \(\) => setState\(\(\) \{
                _selectionMode = false;
                _selectedIds\.clear\(\);
              \}\),
              child: Text\('Cancel \(\$\{_selectedIds\.length\}\)'\),
            \),
          PopupMenuButton<ItemSort>\(
            icon: const Icon\(Icons\.sort\),
            initialValue: currentSort,
            onSelected: \(sort\) \{
              ref\.read\(itemSortProvider\.notifier\)\.state = sort;
            \},
            itemBuilder: \(context\) => const \[
              PopupMenuItem\(
                value: ItemSort\.daysUnused,
                child: Text\('Sort by Days Unused'\),
              \),
              PopupMenuItem\(
                value: ItemSort\.size,
                child: Text\('Sort by Size'\),
              \),
              PopupMenuItem\(
                value: ItemSort\.name,
                child: Text\('Sort by Name'\),
              \),
            \],
          \),
        \],
      \),
      body: Column\(
        children: \[
          // Filter Chips
          SingleChildScrollView\(
            scrollDirection: Axis\.horizontal,
            padding: const EdgeInsets\.symmetric\(horizontal: 16, vertical: 8\),
            child: Row\(
              children: \[
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
          const Divider\(height: 1\),
          // List Body
          Expanded\('''

replacement_scaffold = r'''    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text('Temporary Items'),
            floating: true,
            snap: true,
            actions: [
              if (_selectionMode && _selectedIds.isNotEmpty)
                PopupMenuButton<ItemCategory>(
                  icon: const Icon(Icons.drive_file_move),
                  onSelected: _moveSelected,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: ItemCategory.permanent,
                      child: Text('Move to Permanent'),
                    ),
                    PopupMenuItem(
                      value: ItemCategory.binned,
                      child: Text('Move to Bin'),
                    ),
                  ],
                ),
              if (_selectionMode)
                TextButton(
                  onPressed: () => setState(() {
                    _selectionMode = false;
                    _selectedIds.clear();
                  }),
                  child: Text('Cancel (${_selectedIds.length})'),
                ),
              PopupMenuButton<ItemSort>(
                icon: const Icon(Icons.sort),
                initialValue: currentSort,
                onSelected: (sort) {
                  ref.read(itemSortProvider.notifier).state = sort;
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: ItemSort.daysUnused,
                    child: Text('Sort by Days Unused'),
                  ),
                  PopupMenuItem(
                    value: ItemSort.size,
                    child: Text('Sort by Size'),
                  ),
                  PopupMenuItem(
                    value: ItemSort.name,
                    child: Text('Sort by Name'),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(49.0),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
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
                  const Divider(height: 1),
                ],
              ),
            ),
          ),
        ],
        body: '''

content = re.sub(target_scaffold, replacement_scaffold, content)

# Remove the closing Expanded) bracket
content = content.replace("            ),\n          ),\n        ],\n      ),\n      floatingActionButton", "            ),\n      ),\n      floatingActionButton")

# Add the double FABs
target_fab = r'''      floatingActionButton: FloatingActionButton\(
        onPressed: \(\) => setState\(\(\) \{
          _selectionMode = !_selectionMode;
          _selectedIds\.clear\(\);
        \}\),
        tooltip: _selectionMode \? 'Exit selection' : 'Select items',
        child: Icon\(_selectionMode \? Icons\.close : Icons\.checklist\),
      \),'''

replacement_fab = r'''      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showBackToTop) ...[
            FloatingActionButton.small(
              heroTag: 'temp_to_top',
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
            heroTag: 'temp_select',
            onPressed: () => setState(() {
              _selectionMode = !_selectionMode;
              _selectedIds.clear();
            }),
            tooltip: _selectionMode ? 'Exit selection' : 'Select items',
            child: Icon(_selectionMode ? Icons.close : Icons.checklist),
          ),
        ],
      ),'''

content = re.sub(target_fab, replacement_fab, content)

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
