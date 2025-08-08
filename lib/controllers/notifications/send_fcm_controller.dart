import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/notification/add_notification_model.dart';

final sendNotificationProvider =
    StateNotifierProvider<SendNotificationController, AsyncValue<void>>(
      (ref) => SendNotificationController(),
    );

class SendNotificationController extends StateNotifier<AsyncValue<void>> {
  SendNotificationController() : super(const AsyncData(null));

  final storage = const FlutterSecureStorage();

  Future<void> sendNotification(AddNotificationModel model) async {
    state = const AsyncLoading();

    try {
      final token = await storage.read(key: 'token');
      String sendFcmURL =
          dotenv.env['SEND_FCM_URL'] ?? 'https://defaulturl.com/api';

      final response = await http.post(
        Uri.parse(sendFcmURL), // ✅ Update to your endpoint
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': model.title,
          'notification': model.message,
          'recipientId': model.recipientId,
        }),
      );

      if (response.statusCode == 201) {
        state = const AsyncData(null);
      } else {
        throw Exception('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
