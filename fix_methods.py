import re

with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

# Fix 1: The broken onDoubleTap
target = r"""        onDoubleTap: \(\) async \{
          try \{
            await revealTrackedItem\(ref, item\);
          \} catch \(error\) \{
            if \(mounted\) showItemActionError\(context, error\);
      \),
          \}
        \},
    \);
  \}"""

replacement = r"""        onDoubleTap: () async {
          try {
            await revealTrackedItem(ref, item);
          } catch (error) {
            if (mounted) showItemActionError(context, error);
          }
        },
      ),
    );
  }"""
content = re.sub(target, replacement, content)


# Fix 2: the next broken onDoubleTap (likely line 676)
target2 = r"""        onDoubleTap: \(\) async \{
          try \{
            await _showSystemTrashItemActions\(item\);
      \),
          \} catch \(error\) \{
            if \(mounted\) showItemActionError\(context, error\);
          \}
        \},
    \);
  \}"""

replacement2 = r"""        onDoubleTap: () async {
          try {
            await _showSystemTrashItemActions(item);
          } catch (error) {
            if (mounted) showItemActionError(context, error);
          }
        },
      ),
    );
  }"""
content = re.sub(target2, replacement2, content)

# Fix 3: line 676 actually looks like `await _showSystemTrashItemActions(item);` 
# Let's see what line 676 is exactly by fixing one by one!
with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)

