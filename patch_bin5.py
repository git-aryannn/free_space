with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

import re

target = r'''          IconButton\(
            icon: const Icon\(Icons\.delete_sweep\),
            tooltip: 'Empty Bin',
            onPressed: \(\) => _confirmEmptyBin\(context, ref\),
          \),
        \],
      \),
      body: binItemsAsync\.when\('''

replacement = r'''          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Empty Bin',
            onPressed: () => _confirmEmptyBin(context, ref),
          ),
        ],
      ),
      ],
      body: binItemsAsync.when('''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
