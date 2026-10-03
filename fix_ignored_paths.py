import re
with open("lib/data/services/system_file_scan_service.dart", "r") as f:
    content = f.read()

# Add ignoredPaths to scan
target1 = r"""  Future<SystemScanResult> scan\(
    String rootPath, \{
    required Future<void> Function\(List<TrackedItemModel>\) saveBatch,
    void Function\(int discoveredItems\)\? onProgress,
  \}\) =>
      scanPaths\(
        \[rootPath\],
        saveBatch: saveBatch,
        onProgress: onProgress,
      \);"""
replacement1 = r"""  Future<SystemScanResult> scan(
    String rootPath, {
    required Future<void> Function(List<TrackedItemModel>) saveBatch,
    void Function(int discoveredItems)? onProgress,
    List<String> ignoredPaths = const [],
  }) =>
      scanPaths(
        [rootPath],
        saveBatch: saveBatch,
        onProgress: onProgress,
        ignoredPaths: ignoredPaths,
      );"""
content = re.sub(target1, replacement1, content)

# Add ignoredPaths to scanPaths
target2 = r"""  Future<SystemScanResult> scanPaths\(
    List<String> paths, \{
    required Future<void> Function\(List<TrackedItemModel>\) saveBatch,
    void Function\(int discoveredItems\)\? onProgress,
  \}\) async \{
    if \(paths\.length == 1 &&
      Uri\.tryParse\(paths\.first\)\?\.scheme == 'content'\) \{
      return _scanDocumentTree\(
        paths\.single,
        saveBatch: saveBatch,
        onProgress: onProgress,"""
replacement2 = r"""  Future<SystemScanResult> scanPaths(
    List<String> paths, {
    required Future<void> Function(List<TrackedItemModel>) saveBatch,
    void Function(int discoveredItems)? onProgress,
    List<String> ignoredPaths = const [],
  }) async {
    if (paths.length == 1 &&
      Uri.tryParse(paths.first)?.scheme == 'content') {
      return _scanDocumentTree(
        paths.single,
        saveBatch: saveBatch,
        onProgress: onProgress,
        ignoredPaths: ignoredPaths,"""
content = re.sub(target2, replacement2, content)

# Add to _scanDocumentTree
target3 = r"""  Future<SystemScanResult> _scanDocumentTree\(
    String treeUri, \{
    required Future<void> Function\(List<TrackedItemModel>\) saveBatch,
    void Function\(int discoveredItems\)\? onProgress,
  \}\) async \{"""
replacement3 = r"""  Future<SystemScanResult> _scanDocumentTree(
    String treeUri, {
    required Future<void> Function(List<TrackedItemModel>) saveBatch,
    void Function(int discoveredItems)? onProgress,
    List<String> ignoredPaths = const [],
  }) async {"""
content = re.sub(target3, replacement3, content)

with open("lib/data/services/system_file_scan_service.dart", "w") as f:
    f.write(content)
