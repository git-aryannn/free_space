import re
with open("lib/data/services/system_file_scan_service.dart", "r") as f:
    content = f.read()

target = r"""  Future<SystemScanResult> scanPaths\(
    List<String> paths, \{
    required Future<void> Function\(List<TrackedItemModel>\) saveBatch,
    void Function\(int discoveredItems\)\? onProgress,
  \}\) async \{"""

replacement = r"""  Future<SystemScanResult> scanPaths(
    List<String> paths, {
    required Future<void> Function(List<TrackedItemModel>) saveBatch,
    void Function(int discoveredItems)? onProgress,
    List<String> ignoredPaths = const [],
  }) async {"""
content = re.sub(target, replacement, content)

with open("lib/data/services/system_file_scan_service.dart", "w") as f:
    f.write(content)
