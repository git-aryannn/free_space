import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = r"""                                children: const \[
                                  Text\('Smart Sync',
                                      textAlign: TextAlign\.center,
                                      style: TextStyle\(fontSize: 12\)\),
                                  Text\('\(On open\)',
                                      textAlign: TextAlign\.center,
                                      style: TextStyle\(fontSize: 10\)\),
                                \],"""
replacement = r"""                                children: const [
                                  FittedBox(fit: BoxFit.scaleDown, child: Text('Smart Sync', maxLines: 1, style: TextStyle(fontSize: 12))),
                                  FittedBox(fit: BoxFit.scaleDown, child: Text('(On open)', maxLines: 1, style: TextStyle(fontSize: 10))),
                                ],"""
content = re.sub(target, replacement, content)

target2 = r"""                                children: const \[
                                  Text\('Efficient',
                                      textAlign: TextAlign\.center,
                                      style: TextStyle\(fontSize: 12\)\),
                                  Text\('\(Background\)',
                                      textAlign: TextAlign\.center,
                                      style: TextStyle\(fontSize: 10\)\),
                                \],"""
replacement2 = r"""                                children: const [
                                  FittedBox(fit: BoxFit.scaleDown, child: Text('Efficient', maxLines: 1, style: TextStyle(fontSize: 12))),
                                  FittedBox(fit: BoxFit.scaleDown, child: Text('(Background)', maxLines: 1, style: TextStyle(fontSize: 10))),
                                ],"""
content = re.sub(target2, replacement2, content)

target3 = r"""                                children: const \[
                                  Text\('Live Mode',
                                      textAlign: TextAlign\.center,
                                      style: TextStyle\(fontSize: 12\)\),
                                  Text\('\(Instant\)',
                                      textAlign: TextAlign\.center,
                                      style: TextStyle\(fontSize: 10\)\),
                                \],"""
replacement3 = r"""                                children: const [
                                  FittedBox(fit: BoxFit.scaleDown, child: Text('Live Mode', maxLines: 1, style: TextStyle(fontSize: 12))),
                                  FittedBox(fit: BoxFit.scaleDown, child: Text('(Instant)', maxLines: 1, style: TextStyle(fontSize: 10))),
                                ],"""
content = re.sub(target3, replacement3, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
