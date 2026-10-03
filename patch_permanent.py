with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target = '''        }
        paths = [await nativeService.getDownloadsPath()];
      } else {'''

replacement = '''        }
        final downloadsPath = await nativeService.getDownloadsPath();
        await nativeService.setScanRoot(downloadsPath);
        paths = [downloadsPath];
      } else {'''

content = content.replace(target, replacement)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
