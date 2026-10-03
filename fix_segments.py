import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target1 = r"""                              label: FittedBox\(
                                  fit: BoxFit\.scaleDown,
                                  child: Text\('Smart Sync \(On open\)',
                                      textAlign: TextAlign\.center,
                                      maxLines: 1,
                                      style: TextStyle\(fontSize: 11\)\)\),"""
replacement1 = r"""                              label: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Smart Sync', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                                  Text('(On open)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                                ],
                              ),"""
content = re.sub(target1, replacement1, content)

target2 = r"""                              label: FittedBox\(
                                  fit: BoxFit\.scaleDown,
                                  child: Text\('Efficient \(Background\)',
                                      textAlign: TextAlign\.center,
                                      maxLines: 1,
                                      style: TextStyle\(fontSize: 11\)\)\),"""
replacement2 = r"""                              label: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Efficient', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                                  Text('(Background)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                                ],
                              ),"""
content = re.sub(target2, replacement2, content)


target3 = r"""                              label: FittedBox\(
                                  fit: BoxFit\.scaleDown,
                                  child: Text\('Live Mode \(Instant\)',
                                      textAlign: TextAlign\.center,
                                      maxLines: 1,
                                      style: TextStyle\(fontSize: 11\)\)\),"""
replacement3 = r"""                              label: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Live Mode', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                                  Text('(Instant)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                                ],
                              ),"""
content = re.sub(target3, replacement3, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
