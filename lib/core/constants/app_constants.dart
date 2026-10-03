/// Core application constants
class AppConstants {
  AppConstants._();

  static const int defaultInactivityDays = 30;
  static const int binRetentionDays = 30;

  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;

  static const String appName = 'Free Space';

  static const String methodChannelName = 'com.freespace.app/platform';

  static const Duration scanInterval = Duration(minutes: 15);
}
