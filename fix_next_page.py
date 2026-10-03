import re

with open("lib/presentation/screens/onboarding/onboarding_screen.dart", "r") as f:
    content = f.read()

target = r"""  void _nextPage\(\) \{
    if \(_currentPage == 1 && !_storageAccessGranted\) return;
    if \(_currentPage == 2 && !_notificationsGranted\) return;
    if \(_currentPage < 2\) \{
      _pageController\.animateToPage\(
        _currentPage \+ 1,
        duration: const Duration\(milliseconds: 300\),
        curve: Curves\.easeInOut,
      \);
    \} else \{
      _getStarted\(\);
    \}
  \}"""

replacement = r"""  void _nextPage() {
    if (_currentPage == 2 && !_storageAccessGranted) return;
    if (_currentPage == 3 && !_notificationsGranted) return;
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _getStarted();
    }
  }"""

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/onboarding/onboarding_screen.dart", "w") as f:
    f.write(content)
