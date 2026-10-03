import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/data/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);
