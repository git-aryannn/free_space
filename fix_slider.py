import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = r'''                    const SizedBox\(height: 12\),
                    Text\(
                      \'\'\'Hold & Review Mode:
Items unused for this threshold will move from Permanent to Temporary\.

Auto-Bin Mode:
Items unused for this threshold will move from Permanent to Temporary, and if they remain unused in Temporary for another threshold duration, they automatically move to Bin\.

• Any view/open resets the countdown\.
• Items in the Bin are permanently deleted after 30 days \(this is fixed and cannot be changed\)\.\'\'\','''

replacement = '''                    const SizedBox(height: 12),
                    Row(
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
                      \'\'\'Hold & Review Mode:
Items unused for this threshold will move from Permanent to Temporary.

Auto-Bin Mode:
Items unused for this threshold will move from Permanent to Temporary, and if they remain unused in Temporary for another threshold duration, they automatically move to Bin.

• Any view/open resets the countdown.
• Items in the Bin are permanently deleted after 30 days (this is fixed and cannot be changed).\'\'\','''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)

