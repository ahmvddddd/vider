import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'notification_controller.dart';

final readNotificationProvider = FutureProvider.family.autoDispose<
  Map<String, dynamic>,
  String
>((ref, notificationId) async {
  const storage = FlutterSecureStorage();
  String readNotificationURL =
      dotenv.env['READ_NOTIFICATION_URL'] ?? 'https://defaulturl.com/api';
  final logger = Logger();

  try {
    final token = await storage.read(key: 'token');
    final response = await http.patch(
      Uri.parse('$readNotificationURL$notificationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      // Refresh the list
      ref.invalidate(notificationsProvider);
      return jsonDecode(response.body);
    } else {
      final exception = 'An error occurred';
      try {
        await FirebaseCrashlytics.instance.recordError(
          Exception("Failed to read notifications: ${response.body}"),
          null,
          reason:
              'Delete read notifications API returned error ${response.statusCode}',
        );
      } catch (e) {
        logger.i('Crashlytics read notifications API response failed');
      }
      throw exception;
    }
  } catch (error, stackTrace) {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Read notifications controller failed',
      );
    } catch (e) {
      logger.i('Crashlytics read notifications controller failed $e');
    }
    throw Exception('An error occurred');
  }
});
