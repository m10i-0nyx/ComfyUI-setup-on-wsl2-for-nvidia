wsl.exe -d Ubuntu24.04-ComfyUI -- bash -lc "tmux new -d -s comfyui '/workspace/comfyui/start_comfyui.sh'"
wsl.exe -d Ubuntu24.04-ComfyUI -- tmux ls

REM Bootstrap delay to allow ComfyUI to start
REM Sleep for 10 seconds
timeout /t 10 /nobreak >nul

REM Open ComfyUI in the default web browser
start "" "http://localhost:8188" >nul 2>&1

wsl.exe -d Ubuntu24.04-ComfyUI -- tmux attach -t comfyui -r
