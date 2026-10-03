import re
with open("lib/presentation/providers/items_provider.dart", "r") as f:
    content = f.read()

target = r"""    final result = await ref\.watch\(systemFileScanServiceProvider\)\.scan\(
      root,
      saveBatch: repository\.addDiscoveredItems,
      onProgress: \(count\) \{"""
replacement = r"""    final ignoredPaths = await settingsDao.getIgnoredPaths();
    final result = await ref.watch(systemFileScanServiceProvider).scan(
      root,
      ignoredPaths: ignoredPaths,
      saveBatch: repository.addDiscoveredItems,
      onProgress: (count) {"""
content = re.sub(target, replacement, content)
with open("lib/presentation/providers/items_provider.dart", "w") as f:
    f.write(content)


with open("lib/data/services/background_live_service.dart", "r") as f:
    content = f.read()

target2 = r"""    final result = await scanService\.scan\(
      root,
      saveBatch: repository\.upsertDiscoveredItems,
    \);"""
replacement2 = r"""    final ignoredPaths = await settingsDao.getIgnoredPaths();
    final result = await scanService.scan(
      root,
      ignoredPaths: ignoredPaths,
      saveBatch: repository.upsertDiscoveredItems,
    );"""
content = re.sub(target2, replacement2, content)
with open("lib/data/services/background_live_service.dart", "w") as f:
    f.write(content)
