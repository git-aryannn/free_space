import re

with open("lib/presentation/providers/items_provider.dart", "r") as f:
    content = f.read()

target = r'''final permanentCountProvider = StreamProvider<int>\(\(ref\) \{
  return ref.watch\(itemRepositoryProvider\).watchPermanentCount\(\);
\}\);'''

replacement = '''final permanentCountProvider = StreamProvider<int>((ref) {
  final rootPath = ref.watch(authorizedScanRootPathProvider).valueOrNull;
  return ref.watch(itemRepositoryProvider).watchPermanentCountByRoot(rootPath);
});'''

content = re.sub(target, replacement, content)

with open("lib/presentation/providers/items_provider.dart", "w") as f:
    f.write(content)

