import re
with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

# Replace the specific addListener block
target = r"""    _scrollController\.addListener\(\(\) \{
      if \(_scrollController\.offset > 200 && !_showBackToTop\) \{
        setState\(\(\) => _showBackToTop = true\);
      \} else if \(_scrollController\.offset <= 200 && _showBackToTop\) \{
        setState\(\(\) => _showBackToTop = false\);
      \}
    \}\);"""

content = re.sub(target, "", content)

# Remove unused _showPermanentCount if it isn't used
# but the error says "_showBackToTop is undefined", so we just needed to remove it.

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
