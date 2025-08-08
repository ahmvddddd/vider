import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final changePasswordProvider =
    StateNotifierProvider<ChangePasswordController, AsyncValue<void>>(
      (ref) => ChangePasswordController(),
    );

class ChangePasswordController extends StateNotifier<AsyncValue<void>> {
  ChangePasswordController() : super(const AsyncValue.data(null));

  final _storage = const FlutterSecureStorage();
  final logger = Logger();
  final String changePasswordUrl =
      dotenv.env['CHANGE_PASSWORD_URL'] ?? 'https://defaulturl.com/api';

  Future<void> changePassword({
    required BuildContext context,
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.put(
        Uri.parse(changePasswordUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.data(null);
      } else {
        final body = jsonDecode(response.body);
        final exception = 'Failed to change password';

        try {
          await FirebaseCrashlytics.instance.recordError(
            '${body['message']}',
            null,
            reason: 'Change password API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i("Crashlytics logging failed: $e");
        }

        throw exception;
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error('Failed to change password', stackTrace);
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Change Password controller failed',
      );
    }
  }
}
