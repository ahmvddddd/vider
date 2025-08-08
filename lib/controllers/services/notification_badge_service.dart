import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../screens/messages/chat.dart';
// import '../../screens/notifications/notifications.dart';
import '../notifications/message_notification_controller.dart';
import '../notifications/unread_notifications_controller.dart';
import '../../main.dart'; // ✅ import where your navigatorKey is defined

class NotificationBadgeService {
  final ProviderContainer container;

  NotificationBadgeService({required this.container});

  Future<void> init() async {
    // ✅ Foreground FCM handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("🟥 Foreground FCM received: ${message.messageId}");
      await handleIncomingMessage(message);
    });

    // ✅ Notification tap when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint('🟧 FCM Tap - App Opened: ${message.data}');
      await handleIncomingMessage(message);
    });

    // ✅ Local Notification tap listener
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onNotificationActionTap, // ✅ global function
    );
  }

  /// ✅ Update badge counters and state refresh
  Future<void> handleIncomingMessage(RemoteMessage message) async {
    final type = message.data['type'];
    final unreadMsg = container.read(unreadMessageProvider.notifier);
    final unreadNotifs = container.read(unreadNotificationsProvider.notifier);

    if (type == 'chat') {
      unreadMsg.refresh();
    } else {
      unreadNotifs.refresh();
    }

    final int totalUnread = container.read(unreadMessageProvider) +
        container.read(unreadNotificationsProvider);

    await AwesomeNotifications().setGlobalBadgeCounter(totalUnread);
  }

  Future<void> updateBadgeCount() async {
    final int totalUnread = container.read(unreadMessageProvider) +
        container.read(unreadNotificationsProvider);

    await AwesomeNotifications().setGlobalBadgeCounter(totalUnread);
  }
}


@pragma("vm:entry-point")
Future<void> onNotificationActionTap(ReceivedAction action) async {
  final type = action.payload?['type'];
  debugPrint("🟦 Local Notification tapped: $type");

  if (navigatorKey.currentState == null) return;

  // if (type == 'chat') {
  //   navigatorKey.currentState?.push(
  //     MaterialPageRoute(builder: (_) => ChatScreen()),
  //   );
  // } else if (type == 'notification') {
  //   navigatorKey.currentState?.push(
  //     MaterialPageRoute(builder: (_) => NotificationsScreen()),
  //   );
  // }
}