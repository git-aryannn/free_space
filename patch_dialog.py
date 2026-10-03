import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

content = content.replace("enum _ScanTarget { downloads, anotherFolder }", "enum _ScanTarget { downloads, anotherFolder, fullDevice }")

target = r'''  Future<_ScanTarget\?> _chooseScanTarget\(\) \{
    return showDialog<_ScanTarget>\(
      context: context,
      builder: \(context\) => AlertDialog\(
        title: const Text\('Scan Downloads\?'\),
        content: const Text\(
          'Android blocks the Download folder in its folder picker\. Scanning it '
          'requires All files access in Settings\. This grants Free Space broad '
          'access to shared files on this device, not only Downloads\. You can '
          'choose another folder for narrower access\.',
        \),
        actions: \[
          TextButton\(
            onPressed: \(\) => Navigator\.pop\(context\),
            child: const Text\('Not now'\),
          \),
          TextButton\(
            onPressed: \(\) =>
                Navigator\.pop\(context, _ScanTarget\.anotherFolder\),
            child: const Text\('Choose another folder'\),
          \),
          FilledButton\(
            onPressed: \(\) => Navigator\.pop\(context, _ScanTarget\.downloads\),
            child: const Text\('Continue to Settings'\),
          \),
        \],
      \),
    \);
  \}'''

replacement = '''  Future<_ScanTarget?> _chooseScanTarget() {
    return showModalBottomSheet<_ScanTarget>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Choose a folder to scan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Scan Downloads'),
              subtitle: const Text('Scan all items in the Downloads folder'),
              onTap: () => Navigator.pop(context, _ScanTarget.downloads),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Other Folder'),
              subtitle: const Text('Pick any specific folder to scan'),
              onTap: () => Navigator.pop(context, _ScanTarget.anotherFolder),
            ),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text('Scan Full Device'),
              subtitle: const Text('Scan all files, media, and apps (Requires permission)'),
              onTap: () => Navigator.pop(context, _ScanTarget.fullDevice),
            ),
          ],
        ),
      ),
    );
  }'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)

