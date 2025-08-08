// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class UserIdService {
  final _secureStorage = const FlutterSecureStorage();
  final logger = Logger();

  Future<String?> getCurrentUserId() async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token != null) {
        final decodedToken = parseJwt(token);
        return decodedToken['id'];
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Get userId controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics get userId controller failed $e');
      }
      throw Exception('An error occurred');
    }
    return null;
  }

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = base64Url.decode(base64Url.normalize(parts[1]));
    final payloadMap =
        json.decode(utf8.decode(payload)) as Map<String, dynamic>;
    return payloadMap;
  }
}
