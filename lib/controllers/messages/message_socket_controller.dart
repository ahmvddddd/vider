import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class MessageSocketController {
  late IO.Socket socket;
  final logger = Logger();
  final crashlytics = FirebaseCrashlytics.instance;

  String serverURL = dotenv.env['SERVER_URL'] ?? 'https://defaulturl.com/api';

  void setupSocket({
    required String currentUserId,
    required List participants,
    required Function(List<Map<String, dynamic>>) onMessageHistory,
    required Function(Map<String, dynamic>) onReceiveMessage,
    required Function(Map<String, dynamic>) onUpdateMessage,
    required Function onReconnect,
  }) {
    try {
      socket = IO.io(
        serverURL,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build(),
      );

      socket.onConnect((_) => logger.i('✅ Connected to Socket.IO server'));

      socket.onDisconnect((_) {
        logger.w('⚠️ Disconnected from Socket.IO server');
        onReconnect();
      });

      socket.on('messageHistory', (data) {
        try {
          final messages = List<Map<String, dynamic>>.from(data);
          onMessageHistory(messages);
        } catch (e, stack) {
          crashlytics.recordError(
            e,
            stack,
            reason: 'Error processing messageHistory',
          );
        }
      });

      socket.on('receiveMessage', (data) {
        try {
          onReceiveMessage(Map<String, dynamic>.from(data));
        } catch (e, stack) {
          crashlytics.recordError(
            e,
            stack,
            reason: 'Error processing receiveMessage',
          );
        }
      });

      socket.on('updateMessage', (data) {
        try {
          if (data['receiverId'] == currentUserId ||
              data['senderId'] == currentUserId) {
            onUpdateMessage(Map<String, dynamic>.from(data));
          }
        } catch (e, stack) {
          crashlytics.recordError(
            e,
            stack,
            reason: 'Error processing updateMessage',
          );
        }
      });
    } catch (e, stack) {
      crashlytics.recordError(e, stack, reason: 'Error initializing socket');
    }
  }

  void fetchMessages(List participants) {
    try {
      socket.emit('getMessages', {'participants': participants});
      logger.i('📩 Emitted getMessages');
    } catch (e, stack) {
      crashlytics.recordError(e, stack, reason: 'Error emitting getMessages');
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    try {
      socket.emit('sendMessage', message);
      logger.i('📤 Message sent: $message');
    } catch (e, stack) {
      crashlytics.recordError(e, stack, reason: 'Error sending message');
    }
  }

  void dispose() {
    try {
      socket.disconnect();
      socket.dispose();
      logger.i('🛑 Socket disconnected and disposed');
    } catch (e, stack) {
      crashlytics.recordError(e, stack, reason: 'Error during socket disposal');
    }
  }
}
