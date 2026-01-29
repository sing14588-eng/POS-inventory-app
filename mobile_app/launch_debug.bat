@echo off
TITLE FlowPos - Debug Launcher
echo Attempting to launch Release App...
echo.

cd build\windows\x64\runner\Release
pos_app.exe

echo.
echo ==========================================
echo APP CRASHED OR CLOSED
echo See above for error details.
echo ==========================================
pause
