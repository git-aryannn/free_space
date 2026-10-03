import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = r"""                              label: Column\(
                                mainAxisSize: MainAxisSize\.min,
                                children: const \[
                                  FittedBox\(fit: BoxFit\.scaleDown, child: Text\('Smart Sync', maxLines: 1, style: TextStyle\(fontSize: 12\)\)\),
                                \],
                              \),"""
replacement = r"""                              label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Smart Sync', maxLines: 1, style: TextStyle(fontSize: 12))),"""
content = re.sub(target, replacement, content)

target2 = r"""                              label: Column\(
                                mainAxisSize: MainAxisSize\.min,
                                children: const \[
                                  FittedBox\(fit: BoxFit\.scaleDown, child: Text\('Efficient', maxLines: 1, style: TextStyle\(fontSize: 12\)\)\),
                                \],
                              \),"""
replacement2 = r"""                              label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Efficient', maxLines: 1, style: TextStyle(fontSize: 12))),"""
content = re.sub(target2, replacement2, content)


target3 = r"""                              label: Column\(
                                mainAxisSize: MainAxisSize\.min,
                                children: const \[
                                  FittedBox\(fit: BoxFit\.scaleDown, child: Text\('Live Mode', maxLines: 1, style: TextStyle\(fontSize: 12\)\)\),
                                \],
                              \),"""
replacement3 = r"""                              label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Live Mode', maxLines: 1, style: TextStyle(fontSize: 12))),"""
content = re.sub(target3, replacement3, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
