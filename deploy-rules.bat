@echo off
echo Firebase Chat App - Deployment Script
echo =====================================
echo.

echo Checking Firebase CLI installation...
firebase --version
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Firebase CLI not installed or not in PATH
    echo Please install with: npm install -g firebase-tools
    echo Then run: firebase login
    pause
    exit /b 1
)

echo.
echo Deploying Firestore security rules...
firebase deploy --only firestore:rules --project fir-chat-app-2e3e7

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ SUCCESS: Firestore rules deployed successfully!
    echo.
    echo You can now test the app with:
    echo   flutter run
    echo.
) else (
    echo.
    echo ❌ ERROR: Failed to deploy Firestore rules
    echo Please check your Firebase authentication and project access
    echo.
)

pause
