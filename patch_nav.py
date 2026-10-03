import re

with open("lib/presentation/widgets/adaptive_scaffold.dart", "r") as f:
    content = f.read()

target = r'''            bottomNavigationBar: NavigationBar\(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
            \),'''

replacement = '''            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            ),'''

content = re.sub(target, replacement, content)

with open("lib/presentation/widgets/adaptive_scaffold.dart", "w") as f:
    f.write(content)

