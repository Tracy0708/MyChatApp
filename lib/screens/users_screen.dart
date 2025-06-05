import 'package:flutter/material.dart';
import 'package:firebase_chat_app/services/chat_service.dart';
import 'package:firebase_chat_app/services/auth_service.dart';
import 'package:firebase_chat_app/models/user_model.dart';
import 'package:firebase_chat_app/screens/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startChat(UserModel user) async {
    try {
      final chatId = await _chatService.createOrGetChat(user.uid);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              chatName: user.displayName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oops! Something went wrong 🐞\n$e'),
            backgroundColor: Colors.pinkAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.light(
      primary: const Color(0xFFFFC1CC), // pastel pink
      onPrimary: Colors.white,
      background: const Color(0xFFFFF1F4),
      onBackground: Colors.black87,
    );

    final textTheme = GoogleFonts.quicksandTextTheme(
      Theme.of(context).textTheme,
    );

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Start Cute Chat 💬',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.primary,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search adorable friends 🐰...',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onPrimary.withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.onPrimary.withOpacity(0.15),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // Users list
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _chatService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Oops! Could not load users 🐾',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  );
                }

                List<UserModel> users = snapshot.data ?? [];

                if (_searchQuery.isNotEmpty) {
                  users = users.where((user) {
                    return user.displayName
                            .toLowerCase()
                            .contains(_searchQuery) ||
                        user.email.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No users yet 🐥'
                          : 'No matches found 🧸',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      color: const Color(0xFFFFF8FA),
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFFFFE0E6),
                          backgroundImage: user.photoURL != null
                              ? CachedNetworkImageProvider(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(
                                  user.displayName.isNotEmpty
                                      ? user.displayName[0].toUpperCase()
                                      : 'U',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          user.displayName.isNotEmpty
                              ? user.displayName
                              : 'Mystery Bunny 🐇',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: textTheme.bodyMedium?.copyWith(
                                color:
                                    colorScheme.onBackground.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: user.isOnline
                                        ? Colors.green
                                        : colorScheme.onBackground
                                            .withOpacity(0.4),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  user.isOnline ? '🟢 Online' : '🔘 Offline',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: user.isOnline
                                        ? Colors.green
                                        : colorScheme.onBackground
                                            .withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () => _startChat(user),
                          icon: Icon(
                            Icons.chat_bubble_rounded,
                            color: colorScheme.primary,
                          ),
                          tooltip: 'Chat now 💌',
                        ),
                        onTap: () => _startChat(user),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
