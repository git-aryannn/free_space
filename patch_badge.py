import re

with open("lib/presentation/widgets/adaptive_scaffold.dart", "r") as f:
    content = f.read()

target = r'''              icon: Badge\(
                isLabelVisible: inboxCount > 0,
                label: Text\(inboxCount\.toString\(\)\),
                child: const Icon\(Icons\.inbox_outlined\),
              \),'''

replacement = r'''              icon: Badge(
                isLabelVisible: inboxCount > 0,
                backgroundColor: AppColors.gold,
                textColor: Colors.black,
                label: Text(inboxCount.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                child: const Icon(Icons.inbox_outlined),
              ),'''

content = re.sub(target, replacement, content)

with open("lib/presentation/widgets/adaptive_scaffold.dart", "w") as f:
    f.write(content)

