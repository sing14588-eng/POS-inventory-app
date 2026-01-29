@echo off
TITLE FlowPos - Demo Launcher
echo ==========================================
echo       FlowPos Client Demo Launcher
echo ==========================================
echo.

:: 1. Start Server in a new window
echo [1/2] Starting Backend Server...
start "FlowPos Server" cmd /k "cd /d .\backend && npm start"

:: 2. Wait for server to warm up
echo Waiting for server to initialize (5 seconds)...
timeout /t 5 /nobreak >nul

:: 3. Run the App
echo [2/2] Launching App...
cd .\mobile_app

:: Check if release build exists, otherwise run debug
if exist "build\windows\x64\runner\Release\pos_app.exe" (
    echo Launching Optimized Release App...
    start "" "build\windows\x64\runner\Release\pos_app.exe"
) else (
    echo Release build not found! Launching in Debug mode (Slower)...
    echo TIP: Run 'mobile_app\build_app.bat' first for a faster demo.
    flutter run -d windows
)

echo.
echo System Running. Close this window to keep running in background.
echo.
