@echo off
TITLE FlowPos - Build Android APK
echo.
echo [1/2] Cleaning previous builds...
call flutter clean

echo.
echo [2/2] Building Android APK (Release)...
echo This may take a few minutes...
call flutter build apk --release

if %errorlevel% neq 0 (
    echo.
    echo BUILD FAILED!
    echo Ensure you have Android Studio / Android SDK installed.
    pause
    exit /b
)

echo.
echo BUILD SUCCESS!
echo API KEY is set to: https://api.bnox.online/api (from Constants.dart)
echo.
echo The APK is located here:
echo mobile_app\build\app\outputs\flutter-apk\app-release.apk
echo.
echo You can copy this file to your phone and install it.
pause
