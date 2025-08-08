import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

Future<void> saveFcmTokenToBackend() async {
  final storage = FlutterSecureStorage();
  String firebaseServiceURL =
      dotenv.env['FIREBASE_SERVICE_URL'] ?? 'https://defaulturlcom/api';
  final logger = Logger();

  try {
    final token = await FirebaseMessaging.instance.getToken();
    final authToken = await storage.read(key: 'token');
    if (token != null && authToken != null) {
      final response = await http.post(
        Uri.parse(firebaseServiceURL),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: '{"token": "$token"}',
      );

      if (response.statusCode != 200) {
        final exception = 'An error occurred';
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to save fcm token: ${response.body}"),
            null,
            reason: 'Fcm token API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics save fcm token API response failed');
        }
        throw exception;
      }
    }
  } catch (error, stackTrace) {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Fcm token controller failed',
      );
    } catch (e) {
      logger.i('Crashlytics save fcm token controller failed $e');
    }
    throw Exception('An error occurred');
  }
}
