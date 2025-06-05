import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../utils/utils.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();

    return FutureBuilder<Map<String, dynamic>>(
      future: _getChatInfo(chatService),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            leading: CircleAvatar(child: CircularProgressIndicator()),
            title: Text('Loading...'),
          );
        }

        final chatInfo = snapshot.data!;
        final String chatName = chatInfo['name'] ?? 'Unknown';
        final String? chatImage = chatInfo['image'];
        final bool isOnline = chatInfo['isOnline'] ?? false;
        final int unreadCount = chat.unreadCount[currentUserId] ?? 0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.pink.shade50,
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.pink.shade100,
                  backgroundImage:
                      chatImage != null
                          ? CachedNetworkImageProvider(chatImage)
                          : null,
                  child:
                      chatImage == null
                          ? Text(
                            chatName.isNotEmpty
                                ? chatName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                          : null,
                ),
                if (!chat.isGroup && isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    chatName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                      color: Colors.pink.shade900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (chat.lastMessage != null)
                  Text(
                    Utils.formatChatListTime(chat.lastMessageTime),
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          unreadCount > 0
                              ? Colors.pink.shade700
                              : Colors.grey.shade600,
                      fontWeight:
                          unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    chat.lastMessage?.text ?? 'No messages yet 💌',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          unreadCount > 0
                              ? Colors.grey.shade800
                              : Colors.grey.shade600,
                      fontWeight:
                          unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            trailing:
                chat.lastMessage?.senderId == currentUserId
                    ? Icon(
                      Icons.done_all,
                      size: 18,
                      color: Colors.pink.shade400,
                    )
                    : null,
            onTap: onTap,
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getChatInfo(ChatService chatService) async {
    if (chat.isGroup) {
      return {
        'name': chat.chatName ?? 'Group Chat 💬',
        'image': chat.chatImage,
        'isOnline': false,
      };
    }

    final otherUserId = chat.participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );

    final otherUser = await chatService.getUserById(otherUserId);

    return {
      'name': otherUser?.displayName ?? 'Unknown 🐾',
      'image': otherUser?.photoURL,
      'isOnline': otherUser?.isOnline ?? false,
    };
  }
}
