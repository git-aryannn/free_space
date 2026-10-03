import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target = r"""    final selectedFolderPath = ref.watch\(authorizedScanRootPathProvider\);
    final scanning = _isScanning \|\| initialScanAsync.isLoading;"""

replacement = r"""    final selectedFolderPath = ref.watch(authorizedScanRootPathProvider);
    final scanning = _isScanning || initialScanAsync.isLoading;
    print("DEBUG BUILD: selectedFolderPath = ${selectedFolderPath.valueOrNull}");"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
