import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target = r"""        final page = await ref\.read\(itemRepositoryProvider\)\.getPermanentItemsPage\(
                  type: type,
                  sort: sort,
                  search: _searchQuery,
                  limit: batchSize,
                  offset: offset,
                \);"""

replacement = r"""        final page = await ref.read(itemRepositoryProvider).getPermanentItemsPage(
                  type: type,
                  sort: sort,
                  search: _searchQuery,
                  limit: batchSize,
                  offset: offset,
                  rootPath: ref.read(authorizedScanRootPathProvider).valueOrNull,
                );"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
