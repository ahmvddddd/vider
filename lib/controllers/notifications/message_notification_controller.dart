import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'package:logger/logger.dart';

final unreadMessageProvider = StateNotifierProvider<UnreadMessageNotifier, int>(
  (ref) {
    return UnreadMessageNotifier();
  },
);

class UnreadMessageNotifier extends StateNotifier<int> {
  UnreadMessageNotifier() : super(0) {
    fetchUnreadMessages();
  }

  Future<void> fetchUnreadMessages() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String messageNotificationsURL =
        dotenv.env['MESSAGE_NOTIFICATIONS_URL'] ?? 'https://defaulturl.com/api';
    final logger = Logger();

    try {
      final token = await secureStorage.read(key: 'token');
      final response = await http.get(
        Uri.parse(messageNotificationsURL),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        state = data['unreadCount'];
      } else {
        final exception = 'An error occurred';
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed fetch unread messages: ${response.body}"),
            null,
            reason: 'Unread messages API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i(
            'Crashlytics fetch unread notifications API response failed',
          );
        }
        throw exception;
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Unread messages controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics fetch unread notifications API response failed');
      }
      throw Exception('An error occurred');
    }
  }

  void refresh() {
    fetchUnreadMessages();
  }
}
