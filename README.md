# ComfyUI setup on WSL2 for NVIDIA
WindowsのWSL2(Ubuntu)でComfyUIをセットアップするためのWindows Batchファイル。

> ついでにNVIDIA GPUのCUDA対応版です。

# これは何？
このリポジトリは、WindowsのWSL2上でComfyUIをセットアップするための手順を提供します。  
この手順に従うことで、Windows上で簡単にComfyUIを利用できるようになります。

# ATTENTION(注意事項)
- 下記をよく読み、セキュアな環境構築をしてください  
- このWindows Batchファイルは信用されるサイトからダウンロードしてください。  
  それ以外のサイトでは悪意のあるコードが混入される可能性があります。 
- WindowsのWSL2上でComfyUIをセットアップするためのものです。
- WSL2上でNVIDIA GPUのCUDAを使用することを前提としています。
- WSL2は Dドライブ にインストールされます。  
  その他ドライブにインストールしたい場合は、手動で`2.Install_Linux.bat`内の
  `$DistroPath`を変更してインストールしてください。

## インストール方法

1. WSL2を有効にする  
  `1.Enable_WSL.bat` を実行する  
  管理者権限が必要となるため、UACが表示されたら「はい」を選択してください。

2. Windowsを再起動する  
  WSL2を有効にした後、Windowsを再起動してください。

3. Linux(Ubuntu24.04)をインストールする  
  `2.Install_Linux.bat` を実行する
  インストールには時間がかかります。

4. ComfyUIをセットアップする  
  `3.Setup_ComfyUI.bat` を実行する  
  (アップデート/再インストールするときは 同じく `3.Setup_ComfyUI.bat` を実行してください)

## 利用方法

1. Linux上のディレクトリ(フォルダ)を開く  
  `4.Open_Workspace_Directory.bat` を実行する  
  Explorerが開き、UbuntuのWorkspaceディレクトリが開きます。  
  /workspace/comfyui/models ディレクトリ配下に利用するモデルを配置してください。  

   - モデルの配置例:
     - `/workspace/data/models/checkpoints` 
     - `/workspace/data/models/loras` 

2. ComfyUIを起動する  
  `5.Start_ComfyUI.bat` を実行する  

3. ComfyUIを終了する  
  通常通りWindowsをシャットダウンまたは再起動してください。

4. 次回以降パソコンを起動した際は、`5.Start_ComfyUI.bat` を実行してください。

# LICENSE
This project is licensed under the MIT License.
