import re

with open("lib/presentation/screens/settings/settings_screen.dart", "r") as f:
    content = f.read()

target = r'''class _SettingsCard extends StatelessWidget \{
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SettingsCard\(\{
    required this\.title,
    required this\.subtitle,
    required this\.icon,
    required this\.child,
  \}\);

  @override
  Widget build\(BuildContext context\) \{.*?\}
\}'''

replacement = r'''class _SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String currentValue;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;

  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.currentValue,
    required this.icon,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.gold,
            size: 21,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          '$subtitle\nCurrent: $currentValue',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: child,
          ),
        ],
      ),
    );
  }
}'''

content = re.sub(target, replacement, content, flags=re.DOTALL)

with open("lib/presentation/screens/settings/settings_screen.dart", "w") as f:
    f.write(content)

