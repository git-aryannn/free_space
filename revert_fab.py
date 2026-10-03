import re

def remove_fab(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    # Remove the back-to-top FAB code block
    fab_block = r"""          if \(_showBackToTop\) \.\.\.\[
            FloatingActionButton\.small\(
              heroTag: '[^']+',
              onPressed: \(\) \{
                _nestedScrollViewKey\.currentState\?\.innerController\.animateTo\(
                  0,
                  duration: const Duration\(milliseconds: 300\),
                  curve: Curves\.easeOut,
                \);
                _nestedScrollViewKey\.currentState\?\.outerController\.animateTo\(
                  0,
                  duration: const Duration\(milliseconds: 300\),
                  curve: Curves\.easeOut,
                \);
              \},
              tooltip: 'Scroll to top',
              child: const Icon\(Icons\.keyboard_arrow_up\),
            \),
            const SizedBox\(height: 8\),
          \],
"""
    content = re.sub(fab_block, "", content)
    
    fab_block_old = r"""          if \(_showBackToTop\) \.\.\.\[
            FloatingActionButton\.small\(
              heroTag: '[^']+',
              onPressed: \(\) \{
                _scrollController\.animateTo\(
                  0,
                  duration: const Duration\(milliseconds: 300\),
                  curve: Curves\.easeOut,
                \);
              \},
              tooltip: 'Scroll to top',
              child: const Icon\(Icons\.keyboard_arrow_up\),
            \),
            const SizedBox\(height: 8\),
          \],
"""
    content = re.sub(fab_block_old, "", content)

    # Remove the _nestedScrollViewKey and _showBackToTop
    content = re.sub(r"  final GlobalKey<NestedScrollViewState> _nestedScrollViewKey = GlobalKey<NestedScrollViewState>\(\);\n  bool _showBackToTop = false;\n", "", content)
    
    # Remove NotificationListener body wrapper
    notif_target = r"""body: NotificationListener<ScrollNotification>\(
        onNotification: \(notification\) \{
          if \(notification\.metrics\.axis == Axis\.vertical\) \{
            final offset = notification\.metrics\.pixels;
            if \(offset > 200 && !_showBackToTop\) \{
              setState\(\(\) => _showBackToTop = true\);
            \} else if \(offset <= 200 && _showBackToTop\) \{
              setState\(\(\) => _showBackToTop = false\);
            \}
          \}
          return false;
        \},
        child: """
    content = re.sub(notif_target, "body: ", content)
    
    # In case I didn't replace it yet (PermanentScreen):
    content = re.sub(r"  bool _showBackToTop = false;\n", "", content)

    with open(filepath, "w") as f:
        f.write(content)

remove_fab("lib/presentation/screens/temporary/temporary_screen.dart")
remove_fab("lib/presentation/screens/bin/bin_screen.dart")
remove_fab("lib/presentation/screens/permanent/permanent_screen.dart")
