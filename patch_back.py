import re

with open("lib/presentation/widgets/adaptive_scaffold.dart", "r") as f:
    content = f.read()

content = content.replace("context.go('/settings');", "context.push('/settings');")

with open("lib/presentation/widgets/adaptive_scaffold.dart", "w") as f:
    f.write(content)

with open("lib/presentation/screens/home/home_shell.dart", "r") as f:
    content = f.read()

target = r'''    return AdaptiveScaffold\('''
replacement = '''    return PopScope(
      canPop: widget.navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
        }
      },
      child: AdaptiveScaffold('''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/home/home_shell.dart", "w") as f:
    f.write(content)

