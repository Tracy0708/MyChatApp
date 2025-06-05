# Fix Google Sign-In Authorization Error

## 🚨 Current Error:
```
Access blocked: authorisation error
Storagerelay URI is not allowed for 'NATIVE_ANDROID' client type.
Error 400: invalid_request
```

## ✅ What I've Fixed:
1. ✅ Added `androidClientId` to Firebase options
2. ✅ Verified SHA-1 certificate matches (`96:AC:51:3C:DB:BD:BC:DC:72:8E:81:A6:75:83:A6:34:1C:B0:41:0F`)
3. ✅ Confirmed `google-services.json` has correct configuration

## 🔧 Steps to Fix in Firebase Console:

### 1. Go to Firebase Console
- Navigate to: https://console.firebase.google.com/project/fir-chat-app-2e3e7
- Go to **Authentication** > **Sign-in method**

### 2. Configure Google Sign-In Provider
- Click on **Google** provider
- Make sure it's **Enabled**
- In the **Web SDK configuration** section:
  - **Web client ID**: Should be `139103647006-l3vq96202qpr75vsq579rhf1kfs6sbbj.apps.googleusercontent.com`
  - **Web client secret**: Should be auto-filled

### 3. Check Google Cloud Console OAuth Settings
This is the most likely fix needed:

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials?project=fir-chat-app-2e3e7)
2. Click on the OAuth 2.0 Client ID for Android
3. Verify these settings:
   - **Application type**: Android
   - **Package name**: `com.example.firebase_chat_app`
   - **SHA-1 certificate fingerprint**: `96:AC:51:3C:DB:BD:BC:DC:72:8E:81:A6:75:83:A6:34:1C:B0:41:0F`

### 4. Add Authorized Domains (If Missing)
In Firebase Console > Authentication > Settings > Authorized domains:
- Make sure `fir-chat-app-2e3e7.firebaseapp.com` is listed
- Add `localhost` for local testing

### 5. Check OAuth Consent Screen
In Google Cloud Console > OAuth consent screen:
- Make sure the app is configured
- Add your email as a test user if in testing mode

## 🔄 Alternative Quick Fix:

If the above doesn't work, try regenerating the Google Sign-In configuration:

1. In Firebase Console, go to **Project Settings** > **General**
2. Scroll to **Your apps** section
3. Click on your Android app
4. Download a fresh `google-services.json`
5. Replace the current one in `android/app/google-services.json`

## 🧪 Test the Fix:

After making changes:
1. Stop the current app
2. Run: `flutter clean`
3. Run: `flutter pub get`
4. Run: `flutter run`
5. Try Google Sign-In again

## 📱 Debug Commands:

If you're still having issues, run these to debug:

```cmd
cd "c:\Users\seech\OneDrive\Desktop\firebase-chat-app\firebase_chat_app"
flutter clean
flutter pub get
flutter run --verbose
```

The most likely fix is ensuring the OAuth client in Google Cloud Console is properly configured for Android with the correct SHA-1 fingerprint.
