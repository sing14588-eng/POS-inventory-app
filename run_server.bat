@echo off
TITLE FlowPos - Backend Server
echo ==========================================
echo       FlowPos POS Inventory App
echo       Local Backend Server
echo ==========================================
echo.
echo [1/2] Navigating to backend folder...
cd /d "%~dp0backend"

echo [2/2] Starting server on Port 5050...
echo.
echo TIP: Ensure your Cloudflare Tunnel is running 
echo if you are accessing via api.bnox.online
echo.
call npm start

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to start the server. 
    echo Please make sure Node.js is installed.
)
pause
