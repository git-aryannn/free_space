import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = r"""        return _SettingsCard\(
          title: 'Ignored Folders & Paths',
          subtitle: 'These paths will never be scanned\.',
          icon: Icons\.folder_off_outlined,
          child: Column\("""

replacement = r"""        final pathsCount = ignoredPathsAsync.valueOrNull?.length ?? 0;
        final pathsList = ignoredPathsAsync.valueOrNull ?? [];
        final currentValueText = pathsCount == 0 ? 'Not selected' : (pathsCount == 1 ? pathsList.first : '$pathsCount folders');
        return _SettingsCard(
          title: 'Ignored Folders',
          subtitle: 'These folders will never be scanned.',
          currentValue: currentValueText,
          icon: Icons.folder_off_outlined,
          child: Column("""

content = re.sub(target, replacement, content)

target_btn = r"""                  icon: const Icon\(Icons\.add\),
                  label: const Text\('Add Path'\),"""

replacement_btn = r"""                  icon: const Icon(Icons.add),
                  label: const Text('Add Folder'),"""

content = re.sub(target_btn, replacement_btn, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)
