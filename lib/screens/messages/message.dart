// ignore_for_file: avoid_print, library_prefixes

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../controllers/messages/message_socket_controller.dart';
import '../../controllers/services/user_id_controller.dart';
import '../../controllers/user/user_controller.dart';
import '../../models/user/user_profile_model.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/message_header.dart';

class MessageScreen extends ConsumerStatefulWidget {
  final List<dynamic> participants;
  final String receiverName;
  final String receiverImage;
  const MessageScreen({
    super.key,
    required this.participants,
    required this.receiverName,
    required this.receiverImage,
  });
  @override
  ConsumerState<MessageScreen> createState() => _MessageState();
}

class _MessageState extends ConsumerState<MessageScreen> {
  final storage = const FlutterSecureStorage();
  late IO.Socket socket;
  final UserIdService userIdService = UserIdService();
  final ScrollController _scrollController = ScrollController();
  final MessageSocketController socketController = MessageSocketController();
  List messages = [];
  final TextEditingController _messageController = TextEditingController();
  String? currentUserId;
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    initializeMessaging();

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => HelperFunction.scrollToBottom(_scrollController)
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 500),
    () => HelperFunction.scrollToBottom(_scrollController)
    );
  }

  

  Future<void> initializeMessaging() async {
    await getCurrentUserId();

    socketController.setupSocket(
      currentUserId: currentUserId!,
      participants: widget.participants,
      onMessageHistory: (data) {
        setState(() {
          messages = data;
        });
        HelperFunction.scrollToBottom(_scrollController);
      },
      onReceiveMessage: (data) {
        setState(() {
          messages.add(data);
        });
        HelperFunction.scrollToBottom(_scrollController);
      },
      onUpdateMessage: (data) {
        setState(() {
          messages.add(data);
        });
        HelperFunction.scrollToBottom(_scrollController);
      },
      onReconnect: attemptReconnect,
    );

    socketController.fetchMessages(widget.participants);
  }

  Future<void> getCurrentUserId() async {
    final userId = await userIdService.getCurrentUserId();
    setState(() {
      currentUserId = userId;
    });
  }

  

  void attemptReconnect() {
    Future.delayed(const Duration(seconds: 2), () {
      print('Attempting to reconnect...');
      socketController.socket.connect();
    });
  }

  void sendMessage(String content) {
    if (currentUserId != null && content.isNotEmpty) {
      final receiverId =
          widget.participants[0] == currentUserId
              ? widget.participants[1]
              : widget.participants[0];

      final userState = ref.read(userProvider);

      if (userState is AsyncData<UserProfileModel>) {
        final user = userState.value;

        final message = {
          'participants': widget.participants,
          'senderId': currentUserId,
          'receiverId': receiverId,
          'senderName': user.username,
          'senderImage': user.profileImage,
          'receiverName': widget.receiverName,
          'receiverImage': widget.receiverImage,
          'content': content,
        };

        socketController.sendMessage(message);

        setState(() {
          messages.add(message);
        });

        _messageController.clear();
        HelperFunction.scrollToBottom(_scrollController);
      }
    }
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    socketController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return Scaffold(
      appBar: MessageHeader(
        title: Text(widget.receiverName,
        style: Theme.of(context).textTheme.headlineSmall,),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.spaceBtwItems),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMine = message['senderId'] == currentUserId;

                  return Align(
                    alignment:
                        isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            isMine
                                ? CustomColors.primary
                                : dark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
                      ),
                      child: Text(
                        message['content'],
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color:
                              isMine
                                  ? Colors.white
                                  : dark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        softWrap: true,
                      ),
                    ),
                  );
                },
              ),
            ),
            RoundedContainer(
              radius: Sizes.cardRadiusLg,
              backgroundColor: 
              dark ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(Sizes.xs),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      focusNode: myFocusNode,
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: Theme.of(context).textTheme.labelSmall,
                        fillColor: dark ? CustomColors.dark : CustomColors.light,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: CustomColors.primary,
                      padding: const EdgeInsets.all(Sizes.sm),
                      shape: CircleBorder()
                    ),
                    onPressed: () => sendMessage(_messageController.text),
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
