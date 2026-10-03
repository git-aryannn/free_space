import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

# 1. Update _scanDevice
target1 = r"""      \} else \{
        paths = await nativeService\.selectScanItems\(\);
      \}
      if \(!mounted\) return;
      ref\.invalidate\(authorizedScanRootPathProvider\);
      if \(paths == null \|\| paths\.isEmpty\) \{"""

replacement1 = r"""      } else {
        paths = await nativeService.selectScanItems();
        if (paths != null && paths.isNotEmpty) {
          await nativeService.setScanRoot(paths.first);
        }
      }
      if (!mounted) return;
      ref.invalidate(authorizedScanRootPathProvider);
      if (paths == null || paths.isEmpty) {"""

content = re.sub(target1, replacement1, content)

# 2. Update _PermanentItemsPagedList query
target2 = r"""                key: ValueKey\(
                  '\$\{currentFilter\.name\}\|\$\{currentSort\.name\}\|\$_searchQuery',
                \),
                query: PermanentItemsPageQuery\(
                  filter: currentFilter,
                  sort: currentSort,
                  search: _searchQuery,
                  offset: 0,
                \),"""

replacement2 = r"""                key: ValueKey(
                  '${currentFilter.name}|${currentSort.name}|$_searchQuery|${selectedFolderPath.valueOrNull}',
                ),
                query: PermanentItemsPageQuery(
                  filter: currentFilter,
                  sort: currentSort,
                  search: _searchQuery,
                  offset: 0,
                  rootPath: selectedFolderPath.valueOrNull,
                ),"""

content = re.sub(target2, replacement2, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
