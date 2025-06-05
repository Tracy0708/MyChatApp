import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/models/message_model.dart';
import 'package:firebase_chat_app/models/user_model.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final MessageModel? lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdAt;
  final Map<String, int> unreadCount;
  final String? chatName;
  final String? chatImage;
  final bool isGroup;

  ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
    required this.unreadCount,
    this.chatName,
    this.chatImage,
    this.isGroup = false,
  });
  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage:
          map['lastMessage'] != null
              ? MessageModel.fromMap(map['lastMessage'])
              : null,
      lastMessageTime: _parseDateTime(map['lastMessageTime']),
      createdAt: _parseDateTime(map['createdAt']),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      chatName: map['chatName'],
      chatImage: map['chatImage'],
      isGroup: map['isGroup'] ?? false,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage?.toMap(),
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'unreadCount': unreadCount,
      'chatName': chatName,
      'chatImage': chatImage,
      'isGroup': isGroup,
    };
  }

  ChatModel copyWith({
    String? id,
    List<String>? participants,
    MessageModel? lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    Map<String, int>? unreadCount,
    String? chatName,
    String? chatImage,
    bool? isGroup,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
      chatName: chatName ?? this.chatName,
      chatImage: chatImage ?? this.chatImage,
      isGroup: isGroup ?? this.isGroup,
    );
  }

  String getChatName(String currentUserId, Map<String, UserModel> users) {
    if (isGroup) {
      return chatName ?? 'Group Chat';
    }

    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );

    return users[otherUserId]?.displayName ?? 'Unknown User';
  }

  String? getChatImage(String currentUserId, Map<String, UserModel> users) {
    if (isGroup) {
      return chatImage;
    }

    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );

    return users[otherUserId]?.photoURL;
  }
}
