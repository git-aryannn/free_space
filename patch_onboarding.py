import re

with open("lib/presentation/screens/onboarding/onboarding_screen.dart", "r") as f:
    content = f.read()

target_method = r'''  Future<void> _requestStorageAccess\(\) async \{
    if \(_requestingAccess\) return;
    setState\(\(\) => _requestingAccess = true\);
    try \{
      final nativeService = ref\.read\(nativePlatformServiceProvider\);
      final root = await nativeService\.selectScanRoot\(\);
      if \(!mounted \|\| root == null\) return;
      final granted = await ensureAllFilesAccess\(context, ref\);
      if \(!mounted\) return;
      if \(!granted\) \{
        ScaffoldMessenger\.of\(context\)\.showSnackBar\(
          const SnackBar\(content: Text\('Storage access is required to continue\.'\)\),
        \);
        return;
      \}
      setState\(\(\) => _storageAccessGranted = true\);
      _nextPage\(\);
    \} catch \(error\) \{
      if \(mounted\) \{
        ScaffoldMessenger\.of\(context\)\.showSnackBar\(
          SnackBar\(content: Text\('Could not grant storage access: \$error'\)\),
        \);
      \}
    \} finally \{
      if \(mounted\) setState\(\(\) => _requestingAccess = false\);
    \}
  \}'''

replacement_method = '''  Future<void> _requestStorageAccess() async {
    if (_requestingAccess) return;
    setState(() => _requestingAccess = true);
    try {
      final nativeService = ref.read(nativePlatformServiceProvider);
      final granted = await ensureAllFilesAccess(context, ref);
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage access is required to continue.')),
        );
        return;
      }
      
      // Default to Downloads folder natively to avoid SAF privacy block
      final downloadsPath = await nativeService.getDownloadsPath();
      await nativeService.setScanRoot(downloadsPath);
      
      setState(() => _storageAccessGranted = true);
      _nextPage();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not grant storage access: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _requestingAccess = false);
    }
  }'''

content = re.sub(target_method, replacement_method, content)

target_desc = r'''                description:
                    'Choose the folder to scan, then allow Free Space to manage shared files\. Android requires this access to move documents into or out of Bin\.','''

replacement_desc = '''                description:
                    'Allow Free Space to manage shared files on your device. Android requires this access to automatically scan your Downloads and manage files securely.','''

content = re.sub(target_desc, replacement_desc, content)

with open("lib/presentation/screens/onboarding/onboarding_screen.dart", "w") as f:
    f.write(content)

