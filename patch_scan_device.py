import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target = r'''      if \(scanTarget == _ScanTarget\.downloads\) \{
        final hasAccess = await nativeService\.requestAllFilesAccess\(\);
        if \(!mounted\) return;
        if \(!hasAccess\) \{
          ScaffoldMessenger\.of\(context\)\.showSnackBar\(
            const SnackBar\(
              content: Text\('Access was not granted\. No files were scanned\.'\),
            \),
          \);
          return;
        \}
        final downloadsPath = await nativeService\.getDownloadsPath\(\);
        await nativeService\.setScanRoot\(downloadsPath\);
        paths = \[downloadsPath\];
      \} else \{
        paths = await nativeService\.selectScanItems\(\);
      \}'''

replacement = '''      if (scanTarget == _ScanTarget.downloads || scanTarget == _ScanTarget.fullDevice) {
        final hasAccess = await nativeService.requestAllFilesAccess();
        if (!mounted) return;
        if (!hasAccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access was not granted. No files were scanned.'),
            ),
          );
          return;
        }
        
        if (scanTarget == _ScanTarget.fullDevice) {
          final rootPath = '/storage/emulated/0';
          await nativeService.setScanRoot(rootPath);
          paths = [rootPath];
        } else {
          final downloadsPath = await nativeService.getDownloadsPath();
          await nativeService.setScanRoot(downloadsPath);
          paths = [downloadsPath];
        }
      } else {
        paths = await nativeService.selectScanItems();
      }'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)

