import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Firebase Chat';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  // Notification Channel
  static const String notificationChannelId = 'high_importance_channel';
  static const String notificationChannelName = 'High Importance Notifications';
  static const String notificationChannelDescription =
      'This channel is used for important notifications.';

  // Message Types
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeFile = 'file';

  // User Status
  static const String userStatusOnline = 'online';
  static const String userStatusOffline = 'offline';
  static const String userStatusAway = 'away';

  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryColorDark = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF03DAC5);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);

  // Message Colors
  static const Color sentMessageColor = Color(0xFF2196F3);
  static const Color receivedMessageColor = Color(0xFFE0E0E0);
  static const Color sentMessageTextColor = Colors.white;
  static const Color receivedMessageTextColor = Colors.black87;

  // Online Status Colors
  static const Color onlineColor = Color(0xFF4CAF50);
  static const Color offlineColor = Color(0xFF757575);
  static const Color awayColor = Color(0xFFFF9800);

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double avatarRadius = 20.0;
  static const double largeAvatarRadius = 40.0;

  // Text Sizes
  static const double titleTextSize = 20.0;
  static const double bodyTextSize = 16.0;
  static const double captionTextSize = 12.0;
  static const double smallTextSize = 14.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Limits
  static const int maxMessageLength = 1000;
  static const int maxChatNameLength = 50;
  static const int maxUsernameLength = 30;

  // Default Values
  static const String defaultAvatarUrl = '';
  static const String defaultChatName = 'Chat';
  static const String noInternetMessage = 'No internet connection';
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';

  // Routes (if using named routes)
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String chatRoute = '/chat';
  static const String usersRoute = '/users';
  static const String profileRoute = '/profile';
}
