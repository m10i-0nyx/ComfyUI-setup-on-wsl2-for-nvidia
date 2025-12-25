@echo off

set "SRC_BAT=%~f0"
set "TMP_PS=%TEMP%\temp_install_linux.ps1"

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
# Install WSL2 and Ubuntu on Windows using PowerShell

$env:WSL_UTF8 = 1
$DistroName = "Ubuntu24.04-ComfyUI"
$DistroPath = "D:\WSL\$DistroName"
$DistroUrl = "https://ftp.riken.jp/Linux/ubuntu-releases/noble/ubuntu-24.04.3-wsl-amd64.wsl"
$DistroSHA256 = "c74833a55e525b1e99e1541509c566bb3e32bdb53bf27ea3347174364a57f47c"

# Install : WSL
#winget.exe install --id Microsoft.WSL --source winget

$wslList = wsl.exe --list | Select-String "$DistroName"
if ($wslList) {
    Write-Warning "WSL2($DistroName) is already installed. Unregister and re-import? (y/n)"
    $answer = Read-Host "Type y to continue"
    if ($answer -eq "y") {
        wsl.exe -t "$DistroName"
        wsl.exe --unregister "$DistroName"
        Write-Host "$DistroName has been unregistered."
    }
    else {
        Write-Host "Operation cancelled."
    }
}

# Download Ubuntu24.04
curl.exe -o "$env:TEMP\ubuntu.wsl" $DistroUrl
if (-not (Test-Path "$env:TEMP\ubuntu.wsl")) {
    Write-Error "Failed to download Ubuntu WSL."
    pause
    exit
}

# Verify SHA256
$downloadedHash = (Get-FileHash -Path "$env:TEMP\ubuntu.wsl" -Algorithm SHA256).Hash.ToLower()
if ($downloadedHash -ne $DistroSHA256.ToLower()) {
    Write-Error "SHA256 hash mismatch! Downloaded: $downloadedHash, Expected: $DistroSHA256"
    Write-Warning "Continue despite mismatch? (y/n)"
    $answer = Read-Host "Type y to continue"
    if ($answer -ne "y") {
        Write-Host "Operation cancelled."
        exit
    }
}
else {
    Write-Host "SHA256 hash verified."
}

# Install Ubuntu24.04 Linux
if (Test-Path "$DistroPath") {
    Write-Warning "$DistroPath already exists. Remove and re-import? (y/n)"
    $answer = Read-Host "Type y to continue"
    if ($answer -eq "y") {
        Remove-Item -Path $DistroPath -Recurse -Force
    }
    else {
        Write-Host "Operation cancelled."
    }
}
New-Item -ItemType Directory -Path "$DistroPath" | Out-Null

# Import Ubuntu24.04 into WSL
wsl.exe --import "$DistroName" "$DistroPath" "$env:TEMP\ubuntu.wsl"

$bashScript = @'
#!/bin/bash

apt-get update
apt-get full-upgrade -y --no-install-recommends
apt-get install -y --no-install-recommends curl git aria2 ca-certificates parallel vim tmux sudo

# Create comfyui-user
useradd -m -N -G adm -s /bin/bash comfyui-user
echo "comfyui-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

mkdir -p /workspace
chown comfyui-user /workspace
chmod 755 /workspace

cat << '_EOL_' > /etc/wsl.conf
[boot]
systemd=true

[interop]
enabled = true
appendWindowsPath = false

[automount]
enabled = true
mountFsTab = true

[network]
generateHosts = true
generateResolvConf = true

[user]
default = comfyui-user
_EOL_

cat << '_EOL_' > /etc/tmux.conf
## Keybind
unbind-key C-b
set-option -g prefix C-z
bind-key C-z send-prefix
_EOL_

nvidia-smi

exit

'@

($bashScript -replace "`r`n", "`n") | Set-Content ".\setup_root.sh"
wsl.exe --user root -d $DistroName -- bash -c "bash ./setup_root.sh"

wsl.exe -t $DistroName

$bashScript = @'
#!/bin/bash

cat << '_EOL_' >> ~/.profile
export WORKSPACE_PATH=/workspace
export UV_PYTHON_INSTALL_DIR=/workspace/python
export VENV_PATH=/workspace/python-venv
export COMFYUI_PATH=/workspace/comfyui
_EOL_

exit

'@

($bashScript -replace "`r`n", "`n") | Set-Content ".\setup_comfyui-user.sh"
wsl.exe -d $DistroName -- bash -c "bash ./setup_comfyui-user.sh"

Remove-Item -Path ".\setup_root.sh"
Remove-Item -Path ".\setup_comfyui-user.sh"
