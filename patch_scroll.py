import re

def patch_file(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    # 1. Replace ScrollController with GlobalKey
    # Find:
    #   late final ScrollController _scrollController;
    #   bool _showBackToTop = false;
    #   @override
    #   void initState() { ... }
    #   @override
    #   void dispose() { ... }
    
    state_block_pattern = r"late final ScrollController _scrollController;[\s\S]*?super\.dispose\(\);\n  }"
    replacement_state = r"final GlobalKey<NestedScrollViewState> _nestedScrollViewKey = GlobalKey<NestedScrollViewState>();\n  bool _showBackToTop = false;"
    
    # We might have different forms of this block, let's just do targeted replacements.
    
    # Actually, it's safer to just replace parts.
    content = re.sub(r"late final ScrollController _scrollController;", "final GlobalKey<NestedScrollViewState> _nestedScrollViewKey = GlobalKey<NestedScrollViewState>();", content)
    
    # Remove initState and dispose for _scrollController
    content = re.sub(r"  @override\n  void initState\(\) \{\n    super\.initState\(\);\n    _scrollController = ScrollController\(\);\n    _scrollController\.addListener\(\(\) \{\n      if \(_scrollController\.offset > 200 && !_showBackToTop\) \{\n        setState\(\(\) => _showBackToTop = true\);\n      \} else if \(_scrollController\.offset <= 200 && _showBackToTop\) \{\n        setState\(\(\) => _showBackToTop = false\);\n      \}\n    \}\);\n  \}\n\n  @override\n  void dispose\(\) \{\n    _scrollController\.dispose\(\);\n    super\.dispose\(\);\n  \}\n", "", content)

    # 2. Fix the FAB onPressed
    fab_target = r"_scrollController\.animateTo\([\s\S]*?curve: Curves\.easeOut,\n                \);"
    fab_replacement = r"""_nestedScrollViewKey.currentState?.innerController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                _nestedScrollViewKey.currentState?.outerController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );"""
    content = re.sub(fab_target, fab_replacement, content)

    # 3. Fix NestedScrollView
    # Replace `controller: _scrollController,` with `key: _nestedScrollViewKey,`
    content = re.sub(r"controller: _scrollController,", "key: _nestedScrollViewKey,", content)

    # 4. Wrap body: with NotificationListener
    # This is tricky because the body contents differ per file.
    # In TemporaryScreen: `body: itemsAsync.when(`
    # In BinScreen: `body: binItemsAsync.when(`
    # In PermanentScreen: `body: PermanentItemsPagedList(` (wait, permanent screen has it different)
    
    with open(filepath, "w") as f:
        f.write(content)

patch_file("lib/presentation/screens/temporary/temporary_screen.dart")
patch_file("lib/presentation/screens/bin/bin_screen.dart")

