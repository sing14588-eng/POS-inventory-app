@echo off
TITLE FlowPos - Rebuild & Repair
echo ==========================================
echo       FlowPos Repair Tool
echo ==========================================
echo.
echo [1/3] Cleaning old build files...
cd mobile_app
call flutter clean

echo.
echo [2/3] Building Fresh Windows App...
echo (This will take about 2-3 minutes. Please wait.)
call flutter build windows --release

if %errorlevel% neq 0 (
    echo.
    echo BUILD FAILED!
    pause
    exit /b
)

echo.
echo [3/3] Launching New App...
cd build\windows\x64\runner\Release
start pos_app.exe

echo.
echo SUCCESS! You can close this window.
pause
