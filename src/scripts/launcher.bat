set INSTALL_SCRIPT="install-ddf.ps1"
start /wait powershell -NoLogo -Noninteractive -ExecutionPolicy Bypass -File %ASSET_DIR%\\scripts\\%INSTALL_SCRIPT%