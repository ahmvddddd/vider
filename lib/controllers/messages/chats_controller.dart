// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/chats/chat_model.dart';

final chatsProvider = StateNotifierProvider<ChatController, List<ChatModel>>(
  (ref) => ChatController(),
);

class ChatController extends StateNotifier<List<ChatModel>> {
  ChatController() : super([]);

  final FlutterSecureStorage storage = FlutterSecureStorage();
  final logger = Logger();
  String chatsURL = dotenv.env['CHATS_URL'] ?? 'https://defaulturl.com/api';

  Future<void> fetchChats() async {
    try {
      final token = await storage.read(key: 'token');
      final response = await http.get(
        Uri.parse(chatsURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final chats = data.map((json) => ChatModel.fromJson(json)).toList();
        state = chats;
      } else {
        final exception = 'Failed to load chats';

        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to fetch user chats: ${response.body}"),
            null,
            reason: 'User chats API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics fetch chats failed');
        }
        // Handle server error
        throw exception;
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'User chats controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics Chats controller failed $e');
      }
      throw Exception('Failed to load chats');
    }
  }
}
