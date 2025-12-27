@echo off

set "SRC_BAT=%~f0"
set "TMP_PS=%TEMP%\temp_setup_comfyui.ps1"

REM "REM --- BEGIN POWERSHELL ---"以降を.ps1に書き出し
powershell -NoProfile -Command ^
  "$lines = Get-Content -Raw -Encoding UTF8 '%SRC_BAT%';" ^
  "$split = $lines -split 'REM --- BEGIN POWERSHELL ---\r?\n', 2;" ^
  "if ($split.Count -eq 2) { $split[1] | Set-Content -Encoding UTF8 '%TMP_PS%' } else { Write-Error 'Marker not found.'; exit 1 }"

REM PowerShellスクリプトを実行
powershell -NoProfile -ExecutionPolicy Unrestricted -File "%TMP_PS%"
del "%TMP_PS%"
exit

REM -----------------------------------------------------------------------------------------------

REM --- BEGIN POWERSHELL ---

$env:WSL_UTF8 = 1
$DistroName = "Ubuntu24.04-ComfyUI"

wsl.exe -d $DistroName -- bash -c "bash ./files/setup_comfyui.sh"
