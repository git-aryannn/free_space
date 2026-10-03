import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

# Replace _SettingsCard usages
# 1. Appearance
content = content.replace(
    '''              _SettingsCard(
                title: 'Appearance',
                subtitle: 'Choose your preferred app theme.',
                icon: Icons.palette_outlined,''',
    '''              _SettingsCard(
                title: 'Appearance',
                subtitle: 'Choose your preferred app theme.',
                currentValue: themeMode.name.capitalize(),
                icon: Icons.palette_outlined,'''
)

# 2. Auto-movement
content = content.replace(
    '''              _SettingsCard(
                title: 'Automatic item movement',
                subtitle:
                    'Choose whether inactive Permanent items move to Temporary automatically.',
                icon: Icons.auto_delete_outlined,''',
    '''              _SettingsCard(
                title: 'Automatic item movement',
                subtitle: 'Choose whether inactive items auto-move.',
                currentValue: operationMode == OperationMode.holdReview ? 'Review First' : 'Auto-bin',
                icon: Icons.auto_delete_outlined,'''
)

# 3. Detection Mode
content = content.replace(
    '''              _SettingsCard(
                title: 'New File Detection',
                subtitle: 'How the app detects newly created items.',
                icon: Icons.sync,''',
    '''              _SettingsCard(
                title: 'New File Detection',
                subtitle: 'How the app detects newly created items.',
                currentValue: (detectionModeAsync.valueOrNull ?? DetectionMode.smartSync) == DetectionMode.smartSync ? 'Smart Sync (Battery Saver)' : 'Live Mode (Instant)',
                icon: Icons.sync,'''
)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)

