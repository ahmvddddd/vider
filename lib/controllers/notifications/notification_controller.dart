import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../models/notification/notification_model.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final FlutterSecureStorage storage = FlutterSecureStorage();
String notificationsURL =
    dotenv.env['NOTIFICATIONS_URL'] ?? 'https://defaulturl.com/api';
final logger = Logger();

final notificationsProvider = FutureProvider.autoDispose<
  List<NotificationModel>
>((ref) async {
  try {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse(notificationsURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      final exception = 'Unable to load notifications at this time';
      try {
        await FirebaseCrashlytics.instance.recordError(
          Exception("Failed to fetch notifications: ${response.body}"),
          null,
          reason:
              'Fetch notifications API returned error ${response.statusCode}',
        );
      } catch (e) {
        logger.i('Crashlytics fetch notifications API response failed');
      }
      throw exception;
    }
  } catch (error, stackTrace) {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Fetch notifications controller failed',
      );
    } catch (e) {
      logger.i('Crashlytics fetch notifications controller failed $e');
    }
    throw Exception('Failed to fetch notifications');
  }
});
