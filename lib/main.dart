import 'dart:async';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vider/firebase_options.dart';
import 'app.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final Int64List highVibrationPattern = Int64List.fromList([
  0,
  500,
  1000,
  500,
  2000,
]);

Future<void> main() async {
  runZonedGuarded(
    () async {
      // Ensure Flutter is ready before anything else
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await Firebase.initializeApp(
        name: "vider",
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Load environment variables
      await dotenv.load(fileName: ".env");
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // 🔔 Initialize Awesome Notifications with FCM
      AwesomeNotifications().initialize(null, [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Channel for general alerts',
          importance: NotificationImportance.Max, // 🔥 highest
          playSound: true,
          enableVibration: true,
          vibrationPattern: highVibrationPattern, // custom strong vibration
          criticalAlerts: true, // iOS critical alerts
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          channelShowBadge: true,
        ),
      ]);

      // 🔑 FCM + Awesome Notifications
      await AwesomeNotificationsFcm().initialize(
        onFcmTokenHandle: myFcmTokenHandler,
        onFcmSilentDataHandle: mySilentDataHandler,
      );

      // 🔓 Ask for permission if not already granted
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications(
          permissions: [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
            NotificationPermission.Vibration,
            NotificationPermission.CriticalAlert,
            NotificationPermission.Badge,
          ],
        );
      }

      await FirebaseMessaging.instance.requestPermission();

      NotificationSettings settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      debugPrint('🔔 Permission granted: ${settings.authorizationStatus}');

      runApp(ProviderScope(child: App()));
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Uncaught async error',
        fatal: true,
      );
    },
  );
}

// 🔧 Callback to store FCM token (optional)
@pragma("vm:entry-point")
Future<void> myFcmTokenHandler(String token) async {
  debugPrint('🟦 FCM Token received: $token');
}

// 🔕 Handle background silent push (no notification UI)
@pragma("vm:entry-point")
Future<void> mySilentDataHandler(FcmSilentData data) async {
  debugPrint('🟨 Silent Data: ${data.toString()}');
  if (data.createdLifeCycle != NotificationLifeCycle.Foreground) {
    // Optional: update badge count, refresh data, etc.
  }
}

// 🟢 Handle native device token
@pragma("vm:entry-point")
Future<void> myNativeTokenHandler(String token) async {
  debugPrint('📱 Native Token: $token');
}

// 🔔 Handle foreground push manually (optional override)
@pragma("vm:entry-point")
Future<void> myForegroundHandler(ReceivedAction receivedAction) async {
  debugPrint('📬 Foreground Notification: ${receivedAction.toMap()}');
}
