@echo off
echo Connecting to Android Device...
"C:\Users\sings\AppData\Local\Android\Sdk\platform-tools\adb.exe" reverse tcp:5050 tcp:5050
if %errorlevel% equ 0 (
    echo Connection Established! You can now use the app.
) else (
    echo Failed to connect. Make sure your phone is plugged in and USB debugging is on.
)
pause
