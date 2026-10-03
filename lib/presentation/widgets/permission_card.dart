import 'package:flutter/material.dart';

/// A card to present a required permission to the user and allow them to grant it.
class PermissionCard extends StatelessWidget {
  /// The icon representing the permission.
  final IconData icon;

  /// The title of the permission.
  final String title;

  /// The description of why the permission is needed.
  final String description;

  /// The text for the action button.
  final String buttonText;

  /// Callback when the action button is pressed.
  final VoidCallback onPressed;

  /// Whether the permission has been granted.
  final bool isGranted;

  const PermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.isGranted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isGranted ? const Color(0xFF25D366) : Colors.blue)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isGranted ? const Color(0xFF25D366) : Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: isGranted
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF25D366)),
                        SizedBox(width: 8),
                        Text(
                          'Granted',
                          style: TextStyle(
                            color: Color(0xFF25D366),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(buttonText),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
