import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderPhotoURL;
  final String text;
  final DateTime timestamp;
  final String chatId;
  final MessageType type;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoURL,
    required this.text,
    required this.timestamp,
    required this.chatId,
    this.type = MessageType.text,
  });
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderPhotoURL: map['senderPhotoURL'],
      text: map['text'] ?? '',
      timestamp: _parseDateTime(map['timestamp']),
      chatId: map['chatId'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
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
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoURL': senderPhotoURL,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'chatId': chatId,
      'type': type.name,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderPhotoURL,
    String? text,
    DateTime? timestamp,
    String? chatId,
    MessageType? type,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoURL: senderPhotoURL ?? this.senderPhotoURL,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      chatId: chatId ?? this.chatId,
      type: type ?? this.type,
    );
  }
}

enum MessageType { text, image, file }
