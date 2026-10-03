with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

import re

# 1. Remove duplicate title: const Text('Bin'),
content = content.replace("            title: const Text('Bin'),\n        title: const Text('Bin'),", "            title: const Text('Bin'),")

# 2. Fix NestedScrollView closing bracket
# The original code has:
#       body: RefreshIndicator(
# Wait, I replaced `body: RefreshIndicator(` with `], body: RefreshIndicator(`.
# So the NestedScrollView now closes... wait! Where does it close?
# Let's search for `], body: binItemsAsync.when(`.
# Ah, I replaced `body: binItemsAsync.when(` with nothing? No, my previous script did not touch `body: binItemsAsync.when(`.

# Let's see what is there around `], body:`
