class UserChatState {
  final List chatList;
  final bool isLoading;
  final String senderId;
  final String receiverId;
  final String currentUserId;
  final List<dynamic> participants;

  UserChatState({
    this.chatList = const [],
    this.isLoading = false,
    this.senderId = '',
    this.receiverId = '',
    this.currentUserId = '',
    this.participants = const [],
  });

  UserChatState copyWith({
    List? chatList,
    bool? isLoading,
    String? senderId,
    String? receiverId,
    String? currentUserId,
    List<dynamic>? participants,
  }) {
    return UserChatState(
      chatList: chatList ?? this.chatList,
      isLoading: isLoading ?? this.isLoading,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      currentUserId: currentUserId ?? this.currentUserId,
      participants: participants ?? this.participants,
    );
  }
}

class ChatModel {
  final String senderId;
  final String receiverId;
  final String senderName;
  final String receiverName;
  final String senderImage;
  final String receiverImage;
  final String color;
  final String lastMessage;
  final List<dynamic> participants;
  final DateTime updatedAt;

  ChatModel({
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.receiverName,
    required this.senderImage,
    required this.receiverImage,
    required this.lastMessage,
    required this.participants,
    required this.color,
    required this.updatedAt
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      senderName: json['senderName'] ?? '',
      receiverName: json['receiverName'] ?? '',
      senderImage: json['senderImage'] ?? '',
      receiverImage: json['receiverImage'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      color: json['color'] ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
