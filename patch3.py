with open("lib/presentation/screens/temporary/temporary_screen.dart", "r") as f:
    content = f.read()

import re

target_scaffold = r'''    return Scaffold\(
      appBar: AppBar\(
        title: const Text\('Temporary Storage'\),
        actions: \[
          if \(_selectionMode\)
            TextButton\(
              onPressed: _toggleSelectAllVisible,
              child: Text\(allVisibleSelected \? 'Deselect all' : 'Select all'\),
            \),
          if \(_selectionMode\)
            PopupMenuButton<ItemCategory>\(
              tooltip: 'Move selected items',
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

replacement = r'''    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text('Temporary Storage'),
            floating: true,
            snap: true,
            actions: [
              if (_selectionMode)
                TextButton(
                  onPressed: _toggleSelectAllVisible,
                  child: Text(allVisibleSelected ? 'Deselect all' : 'Select all'),
                ),
              if (_selectionMode)
                PopupMenuButton<ItemCategory>(
                  tooltip: 'Move selected items',
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

content = re.sub(target_scaffold, replacement, content)

# Now fix the ending.
target_end = r'''                error: \(err, stack\) => Center\(
                  child: Text\('Failed to load items:\\n\$err'\),
                \),
              \),
            \),
      \),'''

replacement_end = r'''                error: (err, stack) => Center(
                  child: Text('Failed to load items:\n$err'),
                ),
              ),
            ),
        ),
      ),'''

content = re.sub(target_end, replacement_end, content)

with open("lib/presentation/screens/temporary/temporary_screen.dart", "w") as f:
    f.write(content)
