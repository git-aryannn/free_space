import 'dart:io';

void main() {
  final paths = [
    '/storage/emulated/0/Downloads',
    '/storage/emulated/0/DCIM',
    '/storage/emulated/0/Pictures',
    '/storage/emulated/0/Movies',
  ];

  final startTime = DateTime.now();
  int count = 0;
  for (final path in paths) {
    final dir = Directory(path);
    if (dir.existsSync()) {
      for (final entity in dir.listSync(recursive: true, followLinks: false)) {
        if (entity is File) {
          count++;
        }
      }
    }
  }
  print('Scanned $count files in ${DateTime.now().difference(startTime).inMilliseconds}ms');
}
