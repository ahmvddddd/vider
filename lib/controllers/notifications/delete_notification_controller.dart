import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'notification_controller.dart';

final deleteNotificationProvider = FutureProvider.family.autoDispose<
  void,
  String
>((ref, notificationId) async {
  const storage = FlutterSecureStorage();
  String deleteNotificationURL =
      dotenv.env['DELETE_NOTIFICATION_URL'] ?? 'https://defaulturl.com/api';
  final logger = Logger();

  try {
    final token = await storage.read(key: 'token');
    final response = await http.delete(
      Uri.parse('$deleteNotificationURL$notificationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ref.invalidate(notificationsProvider);
    } else {
      final exception = 'An error occurred';
      try {
        await FirebaseCrashlytics.instance.recordError(
          Exception("Failed to delete notifications: ${response.body}"),
          null,
          reason:
              'Delete notifications API returned error ${response.statusCode}',
        );
      } catch (e) {
        logger.i('Crashlytics delete notifications API response failed');
      }
      throw exception;
    }
  } catch (error, stackTrace) {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Delete notifications controller failed',
      );
    } catch (e) {
      logger.i('Crashlytics delete notifications controller failed $e');
    }
    throw Exception('An error occurred');
  }
});
