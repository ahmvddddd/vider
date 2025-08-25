import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../models/chats/chat_model.dart';
import '../../screens/messages/message.dart';
import '../../utils/helpers/helper_function.dart';

final readChatsProvider =
    StateNotifierProvider<ReadChatController, UserChatState>((ref) {
      return ReadChatController();
    });

class ReadChatController extends StateNotifier<UserChatState> {
  ReadChatController() : super(UserChatState());

  String readChatURL =
      dotenv.env['READ_CHAT_URL'] ?? 'https://defaulturl.com/api';
  final logger = Logger();

  Future<void> readChat(
    BuildContext context,
    String senderId,
    String receiverId,
    String currentUserId,
    String receiverName,
    String receiverImage,
    List<dynamic> participants,
  ) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await http.post(
        Uri.parse(readChatURL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
          'currentUserId': currentUserId,
        }),
      );

      if (response.statusCode == 200) {
        HelperFunction.navigateScreen(
          context,
          MessageScreen(
            participants: participants,
            receiverName: receiverName,
            receiverImage: receiverImage,
          ),
        );
      } else {
        final exception = 'An error occurred';

        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to read user chats: ${response.body}"),
            null,
            reason: 'Read chats API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics wallet API response failed');
        }
        // Handle server error
        throw exception;
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Read chats controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics Read Chats API failed $e');
      }
      throw Exception('An error occurred');
    }
  }
}
