import re

with open("lib/presentation/providers/items_provider.dart", "r") as f:
    content = f.read()

target = r"""    return ref\.watch\(itemRepositoryProvider\)\.getPermanentItemsPage\(
          type: type,
          sort: query\.sort,
          search: query\.search,
          limit: permanentItemsPageSize,
          offset: query\.offset,
        \);"""

replacement = r"""    return ref.watch(itemRepositoryProvider).getPermanentItemsPage(
          type: type,
          sort: query.sort,
          search: query.search,
          limit: permanentItemsPageSize,
          offset: query.offset,
          rootPath: query.rootPath,
        );"""

content = re.sub(target, replacement, content)

with open("lib/presentation/providers/items_provider.dart", "w") as f:
    f.write(content)
