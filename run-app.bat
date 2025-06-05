@echo off
echo Firebase Chat App - Test Runner
echo ===============================
echo.

echo Checking Flutter installation...
flutter --version
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter not installed or not in PATH
    pause
    exit /b 1
)

echo.
echo Getting Flutter dependencies...
flutter pub get

echo.
echo Available options:
echo 1. Run on connected device/emulator
echo 2. Run on Chrome (Web)
echo 3. Run tests
echo.

set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    echo Running on connected device/emulator...
    flutter run
) else if "%choice%"=="2" (
    echo Running on Chrome...
    flutter run -d chrome
) else if "%choice%"=="3" (
    echo Running tests...
    flutter test
) else (
    echo Invalid choice. Running on default device...
    flutter run
)

pause
