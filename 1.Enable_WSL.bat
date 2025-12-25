:: 管理者権限チェック
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo "This script requires administrative privileges."
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

REM 機能を有効化
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:HypervisorPlatform /all /norestart

REM WSLのアップデート
wsl.exe --update

REM Success!
REM Sleep for 10 seconds
timeout /t 10 /nobreak >nul

exit /b 0
