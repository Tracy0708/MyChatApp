# Firebase Chat App Setup Guide

This guide will help you set up your Firebase project to make the chat app fully functional.

## 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name (e.g., "Firebase Chat App")
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## 2. Configure Authentication

1. In your Firebase project, go to **Authentication** > **Sign-in method**
2. Enable **Google** sign-in provider:
   - Click on "Google"
   - Toggle "Enable"
   - Enter your project support email
   - Click "Save"

## 3. Set up Firestore Database

1. Go to **Firestore Database**
2. Click "Create database"
3. Choose "Start in test mode" for now (we'll add security rules later)
4. Select a location closest to your users
5. Click "Done"

## 4. Configure Cloud Messaging (FCM)

1. Go to **Project Settings** (gear icon) > **Cloud Messaging**
2. Note down your **Server key** (you'll need this for sending notifications)

## 5. Configure Android App

### 5.1 Add Android App to Firebase
1. In Firebase Console, click "Add app" and select Android
2. Enter your package name: `com.example.firebase_chat_app`
3. Enter app nickname (optional): "Firebase Chat App"
4. Click "Register app"

### 5.2 Download Configuration File
1. Download the `google-services.json` file
2. Place it in: `android/app/google-services.json`

### 5.3 Configure SHA-1 Certificate
For Google Sign-In to work, you need to add your SHA-1 certificate:

**For Debug (Development):**
```bash
cd android
./gradlew signingReport
```
Look for the SHA1 fingerprint under "Variant: debug" and add it to your Firebase project.

**For Release (Production):**
You'll need to generate a signing key and add its SHA-1 fingerprint.

## 6. Configure iOS App (Optional)

### 6.1 Add iOS App to Firebase
1. In Firebase Console, click "Add app" and select iOS
2. Enter your bundle ID: `com.example.firebaseChatApp`
3. Enter app nickname (optional): "Firebase Chat App iOS"
4. Click "Register app"

### 6.2 Download Configuration File
1. Download the `GoogleService-Info.plist` file
2. Place it in: `ios/Runner/GoogleService-Info.plist`

## 7. Update Firebase Options

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase project configuration:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

You can find these values in:
- Firebase Console > Project Settings > General > Your apps section

## 8. Set Up Firestore Security Rules

In Firestore Database > Rules, replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read other users for chat discovery
    match /users/{userId} {
      allow read: if request.auth != null;
    }
    
    // Chat access rules
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    // Message access rules
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
    }
  }
}
```

## 9. Test the Application

1. Run `flutter pub get` to ensure all dependencies are installed
2. Connect an Android device or start an emulator
3. Run `flutter run` to start the app
4. Test Google Sign-In functionality
5. Try sending messages between different accounts

## 10. Optional: Set Up Cloud Functions for Push Notifications

For automatic push notifications when messages are sent, you can set up Cloud Functions:

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Initialize functions: `firebase init functions`
3. Create a function to send notifications when messages are created

## Troubleshooting

### Common Issues:

1. **Google Sign-In not working:**
   - Ensure SHA-1 certificate is added to Firebase
   - Check that `google-services.json` is in the correct location
   - Verify package name matches in Firebase and `android/app/build.gradle.kts`

2. **Firestore permission denied:**
   - Check that security rules are properly configured
   - Ensure user is authenticated before accessing Firestore

3. **Build errors:**
   - Run `flutter clean` and `flutter pub get`
   - Check that all Firebase dependencies are properly added

4. **FCM not working:**
   - Ensure FCM is enabled in Firebase Console
   - Check notification permissions are granted on device

## Next Steps

Once everything is working:
1. Customize the app's appearance and branding
2. Add more features like image sharing, voice messages, etc.
3. Implement proper error handling and offline support
4. Add comprehensive testing
5. Prepare for production deployment

For production, remember to:
- Update Firestore security rules for production
- Generate proper signing keys for release builds
- Set up proper notification server infrastructure
- Add crash reporting and analytics
