@echo off
TITLE FlowPos - Build Release App
echo.
echo [1/2] Cleaning previous builds...
call flutter clean

echo.
echo [2/2] Building Windows Release (Optimized)...
echo This may take a few minutes...
call flutter build windows --release

if %errorlevel% neq 0 (
    echo.
    echo BUILD FAILED!
    pause
    exit /b
)

echo.
echo BUILD SUCCESS!
echo App acts are located in: build\windows\x64\runner\Release
pause
