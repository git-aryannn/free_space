with open("lib/presentation/screens/home/dashboard_screen.dart", "r") as f:
    dashboard = f.read()

dashboard = dashboard.replace("if (spaceSaved <= 0) return const SizedBox.shrink();", "")

with open("lib/presentation/screens/home/dashboard_screen.dart", "w") as f:
    f.write(dashboard)


with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    settings = f.read()

target = """              const SizedBox(height: 32),
              Text(
                'ABOUT',"""

replacement = """              const SizedBox(height: 32),
              Text(
                'EXCEPTIONS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildIgnoredFoldersSection(context, theme, colorScheme),
              const SizedBox(height: 32),
              Text(
                'ABOUT',"""

settings = settings.replace(target, replacement)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(settings)
