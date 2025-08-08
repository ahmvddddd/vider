import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../models/notification/add_notification_model.dart';

final addNotificationProvider = FutureProvider.family
    .autoDispose<void, AddNotificationModel>((ref, model) async {
      const storage = FlutterSecureStorage();
      final logger = Logger();
      String addNotificationURL =
          dotenv.env['ADD_NOTIFICATION_URL'] ?? 'https://defaulturl.com/api';

      try {
        final token = await storage.read(key: 'token');
        final response = await http.post(
          Uri.parse(addNotificationURL),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(model.toJson()),
        );

        if (response.statusCode != 201) {
          final exception = 'An error occurred';
          try {
            await FirebaseCrashlytics.instance.recordError(
              Exception("Failed to add notifications: ${response.body}"),
              null,
              reason:
                  'Add notifications API returned error ${response.statusCode}',
            );
          } catch (e) {
            logger.i('Crashlytics add notifications API response failed');
          }
          throw exception;
        }
      } catch (error, stackTrace) {
        try {
          await FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            reason: 'Add notifications controller failed',
          );
        } catch (e) {
          logger.i('Crashlytics add notifications controller failed $e');
        }
        throw Exception('An error occurred');
      }
    });
