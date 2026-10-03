import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

# Add _isSearchExpanded state variable
if "bool _isSearchExpanded = false;" not in content:
    content = content.replace("String _searchQuery = '';", "String _searchQuery = '';\n  bool _isSearchExpanded = false;")

# Find the build section where the search field and chips are rendered
target = r'''          Padding\(
            padding: const EdgeInsets\.all\(12\.0\),
            child: TextField\(
              controller: _searchController,
              decoration: InputDecoration\(
                hintText: 'Search permanent items\.\.\.',
                prefixIcon: const Icon\(Icons\.search\),
                border: OutlineInputBorder\(
                  borderRadius: BorderRadius\.circular\(12\),
                \),
                contentPadding: const EdgeInsets\.symmetric\(vertical: 0\),
                suffixIcon: _searchQuery\.isNotEmpty
                    \? IconButton\(
                        icon: const Icon\(Icons\.clear\),
                        onPressed: \(\) \{
                          _searchController\.clear\(\);
                          setState\(\(\) \{
                            _searchQuery = '';
                          \}\);
                        \},
                      \)
                    : null,
              \),
              onChanged: \(value\) \{
                setState\(\(\) \{
                  _searchQuery = value;
                \}\);
              \},
            \),
          \),
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
          \),'''

replacement = '''          Padding(
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
                  autofocus: true,
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
          ),'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)

