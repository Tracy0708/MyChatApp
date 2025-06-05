import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/models/chat_model.dart';
import 'package:firebase_chat_app/models/message_model.dart';
import 'package:firebase_chat_app/models/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  // Get all users (for creating new chats)
  Stream<List<UserModel>> getAllUsers() {
    print('ChatService: Getting all users, current user: $currentUserId');
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .handleError((error) {
          print('Error getting all users: $error');
        })
        .map((snapshot) {
          print('ChatService: Found ${snapshot.docs.length} users');
          final users =
              snapshot.docs
                  .map((doc) {
                    try {
                      final user = UserModel.fromMap(doc.data());
                      print('User found: ${user.displayName} (${user.uid})');
                      return user;
                    } catch (e) {
                      print('Error parsing user document ${doc.id}: $e');
                      return null;
                    }
                  })
                  .where((user) => user != null)
                  .cast<UserModel>()
                  .toList();
          print('ChatService: Returning ${users.length} valid users');
          return users;
        });
  }

  // Get user chats
  Stream<List<ChatModel>> getUserChats() {
    if (currentUserId == null) {
      print('No authenticated user found');
      return Stream.value([]);
    }

    print('Getting chats for user: $currentUserId');

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .handleError((error) {
          print('Error getting user chats: $error');
        })
        .map((snapshot) {
          print('Found ${snapshot.docs.length} chats');
          List<ChatModel> chats =
              snapshot.docs
                  .map((doc) {
                    try {
                      return ChatModel.fromMap(doc.data());
                    } catch (e) {
                      print('Error parsing chat document ${doc.id}: $e');
                      return null;
                    }
                  })
                  .where((chat) => chat != null)
                  .cast<ChatModel>()
                  .toList();
          // Sort locally by lastMessageTime (most recent first)
          chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

          return chats;
        });
  }

  // Get chat messages
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    print('ChatService: Getting messages for chat: $chatId');
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) {
          print('Error getting chat messages: $error');
        })
        .map((snapshot) {
          print(
            'ChatService: Found ${snapshot.docs.length} messages in chat $chatId',
          );
          return snapshot.docs
              .map((doc) {
                try {
                  final message = MessageModel.fromMap(doc.data());
                  print('Message: ${message.text} from ${message.senderName}');
                  return message;
                } catch (e) {
                  print('Error parsing message document ${doc.id}: $e');
                  return null;
                }
              })
              .where((message) => message != null)
              .cast<MessageModel>()
              .toList();
        });
  }

  // Create or get existing chat
  Future<String> createOrGetChat(String otherUserId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Check if chat already exists
    final existingChat =
        await _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .where('isGroup', isEqualTo: false)
            .get();

    for (var doc in existingChat.docs) {
      final chatData = doc.data();
      final participants = List<String>.from(chatData['participants'] ?? []);
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Create new chat
    final chatRef = _firestore.collection('chats').doc();
    final now = DateTime.now();

    final chat = ChatModel(
      id: chatRef.id,
      participants: [currentUserId!, otherUserId],
      lastMessageTime: now,
      createdAt: now,
      unreadCount: {currentUserId!: 0, otherUserId: 0},
      isGroup: false,
    );

    await chatRef.set(chat.toMap());
    return chatRef.id;
  }

  // Send message
  Future<void> sendMessage(String chatId, String text) async {
    print('ChatService: Sending message to chat $chatId: $text');
    if (currentUserId == null) throw Exception('User not authenticated');

    final user = _auth.currentUser!;
    final messageRef =
        _firestore.collection('chats').doc(chatId).collection('messages').doc();

    final now = DateTime.now();
    final message = MessageModel(
      id: messageRef.id,
      senderId: currentUserId!,
      senderName: user.displayName ?? 'Unknown',
      senderPhotoURL: user.photoURL,
      text: text,
      timestamp: now,
      chatId: chatId,
      type: MessageType.text,
    );

    try {
      // Add message to subcollection
      print('ChatService: Adding message to Firestore...');
      await messageRef.set(message.toMap());
      print('ChatService: Message added successfully'); // Update chat document
      print('ChatService: Updating chat document...');
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message.toMap(),
        'lastMessageTime': Timestamp.fromDate(now),
      });
      print('ChatService: Chat document updated successfully');
    } catch (e) {
      print('ChatService: Error sending message: $e');
      throw e;
    }

    // Update unread count for other participants
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (chatDoc.exists) {
      final chatData = chatDoc.data()!;
      final participants = List<String>.from(chatData['participants'] ?? []);
      final unreadCount = Map<String, int>.from(chatData['unreadCount'] ?? {});

      for (String participantId in participants) {
        if (participantId != currentUserId) {
          unreadCount[participantId] = (unreadCount[participantId] ?? 0) + 1;
        }
      }

      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount': unreadCount,
      });
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    if (currentUserId == null) return;

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (chatDoc.exists) {
      final chatData = chatDoc.data()!;
      final unreadCount = Map<String, int>.from(chatData['unreadCount'] ?? {});
      unreadCount[currentUserId!] = 0;

      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount': unreadCount,
      });
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Get multiple users by IDs
  Future<Map<String, UserModel>> getUsersByIds(List<String> userIds) async {
    final Map<String, UserModel> users = {};

    for (String userId in userIds) {
      final user = await getUserById(userId);
      if (user != null) {
        users[userId] = user;
      }
    }

    return users;
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    if (currentUserId == null) return;

    // Delete all messages in the chat
    final messagesQuery =
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .get();

    final batch = _firestore.batch();
    for (var doc in messagesQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete the chat document
    batch.delete(_firestore.collection('chats').doc(chatId));

    await batch.commit();
  }
}
