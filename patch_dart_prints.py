import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target = r"""      if \(!mounted\) return;
      ref\.invalidate\(authorizedScanRootPathProvider\);"""

replacement = r"""      print("DEBUG: paths from selectScanItems: $paths");
      if (!mounted) return;
      ref.invalidate(authorizedScanRootPathProvider);
      final newRoot = await ref.read(nativePlatformServiceProvider).getScanRootDisplayPath();
      print("DEBUG: newRoot after invalidate: $newRoot");"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
