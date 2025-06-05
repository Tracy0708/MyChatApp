@echo off
echo Firebase Chat App - Multi-User Testing Setup
echo =============================================
echo.

echo This script will help you test the chat app with multiple users
echo.

echo Step 1: Starting the app in Chrome...
echo.
start cmd /k "cd /d %cd% && flutter run -d chrome"

echo.
echo Step 2: Wait for the app to load, then:
echo.
echo   1. Note the localhost URL from the terminal (e.g., http://localhost:12345)
echo   2. Sign in with your primary Google account
echo   3. Go to Users screen - you'll see "No users available" (this is normal)
echo.

pause

echo.
echo Step 3: Opening incognito window for second user...
echo.
echo   4. Open Chrome incognito window (Ctrl+Shift+N)
echo   5. Go to the SAME localhost URL from step 2
echo   6. Sign in with a DIFFERENT Google account
echo.

pause

echo.
echo Step 4: Testing the chat...
echo.
echo   7. In both windows, go to Users screen (+ button)
echo   8. You should now see each other in the users list!
echo   9. Click on a user to start chatting
echo   10. Type messages in one window - they should appear in the other
echo.

echo ✅ Success! You now have a working multi-user chat app!
echo.
echo 💡 Tips:
echo   - Keep both windows open side by side
echo   - Try sending messages from both accounts
echo   - Messages should appear in real-time
echo   - You can create multiple chats between the same users
echo.

pause
