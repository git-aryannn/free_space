import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

target = r'''                child: IconButton\(
                  onPressed: \(\) => _revealPermanentCount\(
                    permCountAsync\.valueOrNull \?\? 0,
                  \),
                  icon: Badge\(
                    isLabelVisible: _showPermanentCount,
                    label: Text\(
                      permCountAsync\.valueOrNull\?\.toString\(\) \?\? '0',
                    \),
                    child: const Icon\(Icons\.lock_outline\),
                  \),
                \),'''

replacement = '''                child: IconButton(
                  onPressed: () => _revealPermanentCount(
                    permCountAsync.valueOrNull ?? 0,
                  ),
                  icon: const Icon(Icons.lock_outline),
                ),'''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)

