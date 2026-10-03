import re

with open("lib/data/repositories/item_repository.dart", "r") as f:
    content = f.read()

target = r'''  ItemType _determineType\(String path\) \{
    final ext = path\.split\('\.'\)\.last\.toLowerCase\(\);
    if \(\['jpg', 'jpeg', 'png', 'gif', 'webp'\]\.contains\(ext\)\) return ItemType\.image;
    if \(\['mp4', 'mkv', 'avi', 'mov'\]\.contains\(ext\)\) return ItemType\.video;
    if \(\['mp3', 'wav', 'aac', 'flac'\]\.contains\(ext\)\) return ItemType\.audio;
    if \(\['pdf', 'doc', 'docx', 'txt'\]\.contains\(ext\)\) return ItemType\.document;
    if \(\['apk', 'aab'\]\.contains\(ext\)\) return ItemType\.app;
    return ItemType\.other;
  \}'''

replacement = '''  ItemType _determineType(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'mp4', 'mkv', 'avi', 'mov', 'mp3', 'wav', 'aac', 'flac'].contains(ext)) {
      return ItemType.media;
    }
    if (['apk', 'aab'].contains(ext)) {
      return ItemType.app;
    }
    return ItemType.file;
  }'''

content = re.sub(target, replacement, content)

with open("lib/data/repositories/item_repository.dart", "w") as f:
    f.write(content)

