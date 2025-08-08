import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'package:logger/logger.dart';

final unreadNotificationsProvider =
    StateNotifierProvider<UnreadNotificationsNotifier, int>((ref) {
      return UnreadNotificationsNotifier();
    });

class UnreadNotificationsNotifier extends StateNotifier<int> {
  UnreadNotificationsNotifier() : super(0) {
    fetchUnreadMessages();
  }

  Future<void> fetchUnreadMessages() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String unreadNotificationsURL =
        dotenv.env['UNREAD_NOTIFICATIONS_URL'] ?? 'https://defaulturl.com/api';
    final logger = Logger();

    try {
      final token = await secureStorage.read(key: 'token');
      final response = await http.get(
        Uri.parse(unreadNotificationsURL),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        state = data['unreadCount'];
      } else {
        final exception = 'An error occurred';
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to fetch unread notifications: ${response.body}"),
            null,
            reason:
                'Unread notifications API returned error ${response.statusCode}',
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
          reason: 'Unread notifications controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics fetch unread notifications controller failed $e');
      }
      throw Exception('Ann error occured');
    }
  }

  void refresh() {
    fetchUnreadMessages();
  }
}
