import re
with open("lib/presentation/screens/onboarding/onboarding_screen.dart", "r") as f:
    content = f.read()

# Change the number of dots
content = content.replace("List.generate(3,", "List.generate(4,")

# Change the Next button logic
content = content.replace("_currentPage == 2\n                          ? _getStarted\n                          : _nextPage", "_currentPage == 3\n                          ? _getStarted\n                          : _nextPage")
content = content.replace("_currentPage == 2 ? 'Get Started' : 'Next'", "_currentPage == 3 ? 'Get Started' : 'Next'")

# Change the disabled logic
content = content.replace("(_currentPage == 1 && !_storageAccessGranted) ||\n                          (_currentPage == 2 && !_notificationsGranted)", "(_currentPage == 2 && !_storageAccessGranted) ||\n                          (_currentPage == 3 && !_notificationsGranted)")

# Insert the How It Works slide
target = r"""            children: \[
              _buildWelcomePage\(\),
              _buildPermissionPage\("""

replacement = r"""            children: [
              _buildWelcomePage(),
              _buildHowItWorksPage(),
              _buildPermissionPage("""
content = re.sub(target, replacement, content)

# Add _buildHowItWorksPage method
target2 = r"""  Widget _buildPermissionPage\(\{"""
replacement2 = r"""  Widget _buildHowItWorksPage() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.autorenew, size: 80, color: colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            'How it works',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          _buildStepRow(
            icon: Icons.all_inbox,
            title: '1. Permanent',
            desc: 'Unused files drop down to Temporary after a few days.',
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          _buildStepRow(
            icon: Icons.hourglass_bottom,
            title: '2. Temporary',
            desc: 'Files wait here. If unused for 7 days, they move to Bin.',
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildStepRow(
            icon: Icons.delete_outline,
            title: '3. System Bin',
            desc: 'Safely binned. Deleted forever only when OS limit hits.',
            color: Colors.red,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStepRow({required IconData icon, required String title, required String desc, required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionPage({"""
content = re.sub(target2, replacement2, content)

with open("lib/presentation/screens/onboarding/onboarding_screen.dart", "w") as f:
    f.write(content)
