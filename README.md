# firebase_chat_app

A new Flutter project.

## Getting Started

# Firebase Chat App

A modern, real-time chat application built with Flutter and Firebase, featuring Google Sign-In authentication, real-time messaging, and push notifications.

## Features

✅ **Authentication**
- Google Sign-In integration
- Automatic user profile creation
- Secure authentication flow

✅ **Real-time Messaging**
- Instant message delivery using Firestore streams
- Message timestamps and read status
- Beautiful message bubbles with sender identification

✅ **User Management**
- Online/offline status tracking
- User discovery and chat initiation
- Profile management with avatars

✅ **Push Notifications**
- Firebase Cloud Messaging (FCM) integration
- Local notification display
- Notification token management

✅ **Modern UI/UX**
- Material Design 3 components
- Responsive layout
- Smooth animations and transitions
- Dark/light theme support

## Tech Stack

- **Frontend:** Flutter
- **Backend:** Firebase
  - Firestore (Database)
  - Firebase Auth (Authentication)
  - Firebase Cloud Messaging (Notifications)
- **State Management:** Provider pattern
- **UI Components:** Material Design 3

## Project Structure

```
lib/
├── models/           # Data models
│   ├── user_model.dart
│   ├── chat_model.dart
│   └── message_model.dart
├── services/         # Business logic
│   ├── auth_service.dart
│   ├── chat_service.dart
│   └── notification_service.dart
├── screens/          # UI screens
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── users_screen.dart
│   └── chat_screen.dart
├── widgets/          # Reusable UI components
│   ├── chat_tile.dart
│   ├── message_bubble.dart
│   └── loading_widget.dart
├── utils/            # Helper functions
│   ├── constants.dart
│   ├── utils.dart
│   └── error_handler.dart
├── firebase_options.dart
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase project
- Android Studio/VS Code
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd firebase_chat_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase:**
   - Follow the detailed setup guide in `SETUP_GUIDE.md`
   - Configure Firebase project
   - Add configuration files
   - Update security rules

4. **Run the app:**
   ```bash
   flutter run
   ```

## Configuration

### Firebase Setup
See `SETUP_GUIDE.md` for detailed Firebase configuration instructions.

### Android Configuration
- Package name: `com.example.firebase_chat_app`
- Min SDK: 21
- Target SDK: 34

### iOS Configuration
- Bundle ID: `com.example.firebaseChatApp`
- iOS Deployment Target: 12.0

## Key Components

### Authentication Service
Handles Google Sign-In and user session management:
- `signInWithGoogle()` - Google OAuth flow
- `signOut()` - User logout
- `createUserDocument()` - Firestore user creation

### Chat Service
Manages chat operations and real-time messaging:
- `sendMessage()` - Send text messages
- `getChatsStream()` - Real-time chat updates
- `getMessagesStream()` - Real-time message updates

### Notification Service
Handles FCM and local notifications:
- `initializeNotifications()` - Setup FCM
- `handleMessage()` - Process incoming notifications
- `sendNotification()` - Send push notifications

## Security

### Firestore Rules
The app implements secure Firestore rules:
- Users can only access their own data
- Chat participants can read/write chat messages
- Proper authentication checks

### Authentication
- Secure Google OAuth 2.0 flow
- Firebase Auth token management
- Automatic session handling

## Testing

Run tests with:
```bash
flutter test
```

## Build for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Check the `SETUP_GUIDE.md` for setup issues
- Review Firebase documentation
- Open an issue on GitHub

## Roadmap

Future enhancements planned:
- [ ] Image and file sharing
- [ ] Voice messages
- [ ] Group chat management
- [ ] Message search
- [ ] Chat themes
- [ ] End-to-end encryption
- [ ] Video calling integration

## Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- Material Design team for UI guidelines
