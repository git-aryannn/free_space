with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    settings = f.read()

target = """              const SizedBox(height: 16),
              _SettingsCard(
                title: 'About',"""

replacement = """              const SizedBox(height: 16),
              _buildIgnoredFoldersSection(context, theme, colorScheme),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'About',"""

settings = settings.replace(target, replacement)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(settings)
