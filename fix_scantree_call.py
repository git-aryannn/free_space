import re
with open("lib/data/services/system_file_scan_service.dart", "r") as f:
    content = f.read()

target = r"""      return _scanDocumentTree\(
        paths\.single,
        saveBatch: saveBatch,
        onProgress: onProgress,
      \);"""

replacement = r"""      return _scanDocumentTree(
        paths.single,
        saveBatch: saveBatch,
        onProgress: onProgress,
        ignoredPaths: ignoredPaths,
      );"""

content = re.sub(target, replacement, content)
with open("lib/data/services/system_file_scan_service.dart", "w") as f:
    f.write(content)
