import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

# Add _isEditingInactivity to state
state_target = r'''class _SettingsScreenState extends ConsumerState<SettingsScreen> \{
  int\? _draftInactivityDays;
  bool _saving = false;'''
state_replacement = '''class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int? _draftInactivityDays;
  bool _saving = false;
  bool _isEditingInactivity = false;'''
content = re.sub(state_target, state_replacement, content)

# Change save logic to also disable editing
save_target = r'''          _draftInactivityDays = null;
          _saving = false;
        \}\);'''
save_replacement = '''          _draftInactivityDays = null;
          _saving = false;
          _isEditingInactivity = false;
        });'''
content = re.sub(save_target, save_replacement, content)

# Change the UI of the threshold
ui_target = r'''                    Row\(
                      mainAxisAlignment: MainAxisAlignment\.spaceBetween,
                      children: \[
                        Text\(
                          'Inactivity threshold',
                          style: theme\.textTheme\.titleSmall\?\.copyWith\(
                            fontWeight: FontWeight\.w600,
                          \),
                        \),
                        Text\(
                          '\$inactivityDays days',
                          style: theme\.textTheme\.titleSmall\?\.copyWith\(
                            color: colorScheme\.primary,
                            fontWeight: FontWeight\.bold,
                          \),
                        \),
                      \],
                    \),
                    if \(inactivityDaysAsync\.hasError\) \.\.\.\[
                      const SizedBox\(height: 8\),
                      Text\(
                        'Could not load saved threshold: \$\{inactivityDaysAsync\.error\}',
                        style: TextStyle\(color: colorScheme\.error\),
                      \),
                    \],
                    Slider\(
                      value: inactivityDays\.clamp\(7, 90\)\.toDouble\(\),
                      min: 7,
                      max: 90,
                      divisions: 83,
                      label: '\$inactivityDays days',
                      onChanged: _saving
                          \? null
                          : \(value\) \{
                              setState\(\(\) \{
                                _draftInactivityDays = value\.round\(\);
                              \}\);
                            \},
                      onChangeEnd: _saving
                          \? null
                          : \(value\) => _saveInactivityDays\(value\.round\(\)\),
                    \),
                    Text\(
                      'Items become inactive after this many days without use\.',
                      style: theme\.textTheme\.bodySmall\?\.copyWith\(
                        color: colorScheme\.onSurfaceVariant,
                      \),
                    \),'''

ui_replacement = '''                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Inactivity threshold',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!_isEditingInactivity) ...[
                          Text(
                            '$inactivityDays days',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => setState(() {
                              _isEditingInactivity = true;
                              _draftInactivityDays = savedDays;
                            }),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                          ),
                        ],
                      ],
                    ),
                    if (inactivityDaysAsync.hasError) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Could not load saved threshold: ${inactivityDaysAsync.error}',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                    if (_isEditingInactivity) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: inactivityDays.clamp(7, 90).toDouble(),
                              min: 7,
                              max: 90,
                              divisions: 83,
                              label: '$inactivityDays days',
                              onChanged: _saving
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _draftInactivityDays = value.round();
                                      });
                                    },
                            ),
                          ),
                          Text(
                            '$inactivityDays days',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _saving
                                ? null
                                : () => setState(() {
                                      _isEditingInactivity = false;
                                      _draftInactivityDays = null;
                                    }),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _saving
                                ? null
                                : () => _saveInactivityDays(inactivityDays),
                            child: _saving
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      'If an item remains unused for this many continuous days, it will be moved to the bin if Auto-Bin mode is chosen. Items in the bin will be permanently deleted after 30 days automatically (this is fixed and cannot be changed).',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),'''
content = re.sub(ui_target, ui_replacement, content)

# Remove the old text that was tied to operation mode
old_text_target = r'''                    Text\(
                      \(operationMode\.valueOrNull \?\? OperationMode\.holdReview\) ==
                              OperationMode\.autoBin
                          \? 'Permanent items unused for \$inactivityDays days move to Temporary\. Temporary items move to Bin after their countdown in either mode\.'
                          : 'Permanent items stay until you move them\. Temporary items move to Bin after \$inactivityDays days\.',
                      style: theme\.textTheme\.bodySmall\?\.copyWith\(
                        color: colorScheme\.onSurfaceVariant,
                      \),
                    \),
                    const SizedBox\(height: 24\),'''
content = re.sub(old_text_target, "                    const SizedBox(height: 12),", content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)

