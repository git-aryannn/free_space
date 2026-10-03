import re

with open("lib/presentation/widgets/adaptive_scaffold.dart", "r") as f:
    content = f.read()

# Add imports for Riverpod and inboxProvider
if "import 'package:flutter_riverpod/flutter_riverpod.dart';" not in content:
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../providers/inbox_provider.dart';"
    )

# Change AdaptiveScaffold to ConsumerStatefulWidget if it is not
# Wait, let's just make the AppBar a Consumer widget inside the _buildAppBar
# Or I can just wrap the Icon with Consumer.

target = r'''      actions: \[
        IconButton\(
          tooltip: 'Settings','''

replacement = r'''      actions: [
        Consumer(
          builder: (context, ref, child) {
            final inboxCount = ref.watch(inboxProvider).pendingItems.length;
            return IconButton(
              tooltip: 'Inbox',
              icon: Badge(
                isLabelVisible: inboxCount > 0,
                label: Text(inboxCount.toString()),
                child: const Icon(Icons.inbox_outlined),
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              onPressed: () {
                context.push('/inbox');
              },
            );
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Settings','''

content = re.sub(target, replacement, content)

with open("lib/presentation/widgets/adaptive_scaffold.dart", "w") as f:
    f.write(content)

