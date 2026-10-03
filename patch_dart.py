with open("lib/data/services/native_platform_service.dart", "r") as f:
    content = f.read()

target = '''  Future<String> getDownloadsPath() async {
    final path = await _channel.invokeMethod<String>('getDownloadsPath');
    if (path == null || path.isEmpty) {
      throw const FormatException('Android did not return the Downloads path.');
    }
    return path;
  }'''

replacement = '''  Future<String> getDownloadsPath() async {
    final path = await _channel.invokeMethod<String>('getDownloadsPath');
    if (path == null || path.isEmpty) {
      throw const FormatException('Android did not return the Downloads path.');
    }
    return path;
  }

  Future<void> setScanRoot(String path) async {
    await _channel.invokeMethod('setScanRoot', {'path': path});
  }'''

content = content.replace(target, replacement)

with open("lib/data/services/native_platform_service.dart", "w") as f:
    f.write(content)
