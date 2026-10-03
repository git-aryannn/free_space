import 'package:flutter/material.dart';

/// Utilities for date and time operations
class AppDateUtils {
  AppDateUtils._();

  /// Calculates days since the given date
  static int daysSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inDays;
  }

  /// Formats the number of days unused
  static String formatDaysUnused(int days) {
    if (days == 0) return 'Today';
    if (days == 1) return '1 day';
    return '$days days';
  }

  /// Formats a relative date string
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final month = months[date.month - 1];
      return '$month ${date.day}, ${date.year}';
    }
  }

  /// Gets color indicator based on days and a threshold
  static Color getDaysColor(int days, int threshold) {
    if (threshold <= 0) return Colors.green;
    final ratio = days / threshold;
    if (ratio < 0.5) return Colors.green;
    if (ratio <= 0.8) return Colors.orange;
    return Colors.red;
  }
}
