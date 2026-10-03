import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = r"""        return Card\(
          elevation: 0,
          shape: RoundedRectangleBorder\(
            borderRadius: BorderRadius\.circular\(16\),
            side: BorderSide\(color: theme\.dividerColor\.withValues\(alpha: 0\.1\)\),
          \),
          clipBehavior: Clip\.antiAlias,
          child: ExpansionTile\(
            title: const Text\('Ignored Folders & Paths'\),
            subtitle: const Text\('These paths will never be scanned'\),
            leading: Icon\(Icons\.folder_off_outlined, color: AppColors\.gold\),
            children: \["""

replacement = r"""        return _SettingsCard(
          title: 'Ignored Folders & Paths',
          subtitle: 'These paths will never be scanned.',
          icon: Icons.folder_off_outlined,
          child: Column(
            children: ["""

content = re.sub(target, replacement, content)

target2 = r"""              const SizedBox\(height: 8\),
            \],
          \),
        \);"""

replacement2 = r"""              const SizedBox(height: 8),
            ],
          ),
        );"""

content = re.sub(target2, replacement2, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
