// lib/controllers/notifications/notification_listeners.dart

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';

/// 🔔 Top-level background-safe handler for notification taps
@pragma("vm:entry-point")
Future<void> onNotificationActionTap(ReceivedAction action) async {
  debugPrint('🔔 Notification tapped: ${action.payload}');
  // You can handle navigation or logic here based on action.payload['type']
}
