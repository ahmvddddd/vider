import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth/sign_out_controller.dart';

class TokenSecureStorage {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Checks if token exists. If not, signs out the user.
  static Future<void> checkToken({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      ref.read(signoutControllerProvider.notifier).signOut(context);
    }
  }
}
