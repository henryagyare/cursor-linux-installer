#!/bin/bash
set -e

INSTALL_DIR="/opt"
APP_DIR_NAME="Cursor"
FINAL_APP_PATH="$INSTALL_DIR/$APP_DIR_NAME"
EXECUTABLE_SYMLINK="/usr/local/bin/cursor"
ICON_NAME="cursor.png"
DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"
TEMP_DOWNLOAD_DIR=$(mktemp -d)

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (e.g. with sudo)."
  exit 1
fi

echo "--> Installing dependencies..."
apt-get update -qq
apt-get install -y jq curl wget libfuse2 > /dev/null

echo "--> Fetching latest Cursor AppImage URL..."
LATEST_URL=$(curl -s 'https://cursor.com/api/download?platform=linux-x64&releaseTrack=latest' | jq -r '.downloadUrl')
if [ -z "$LATEST_URL" ] || [ "$LATEST_URL" == "null" ]; then
    echo "Error: Failed to retrieve Cursor download URL."
    exit 1
fi

echo "--> Downloading Cursor..."
wget --show-progress -O "$TEMP_DOWNLOAD_DIR/Cursor.AppImage" "$LATEST_URL"

chmod +x "$TEMP_DOWNLOAD_DIR/Cursor.AppImage"

echo "--> Removing old installation..."
rm -rf "$FINAL_APP_PATH"

echo "--> Extracting..."
(cd "$TEMP_DOWNLOAD_DIR" && ./Cursor.AppImage --appimage-extract)
mv "$TEMP_DOWNLOAD_DIR/squashfs-root" "$FINAL_APP_PATH"

echo "--> Fixing chrome-sandbox permissions..."
SANDBOX_PATH=$(find "$FINAL_APP_PATH" -type f -name chrome-sandbox | head -n 1 || true)
if [ -n "$SANDBOX_PATH" ]; then
    chmod 4755 "$SANDBOX_PATH"
    echo "Setuid bit applied to $SANDBOX_PATH"
else
    echo "Warning: chrome-sandbox not found. You may need to run Cursor with --no-sandbox if it fails."
fi

echo "--> Creating symlink..."
ln -sf "$FINAL_APP_PATH/AppRun" "$EXECUTABLE_SYMLINK"

echo "--> Creating desktop entry..."
cat > "$DESKTOP_ENTRY_PATH" <<EOL
[Desktop Entry]
Name=Cursor
Comment=The AI-first Code Editor
Icon=$FINAL_APP_PATH/cursor.png
Exec=$EXECUTABLE_SYMLINK
Type=Application
Categories=Development;IDE;
Terminal=false
EOL

chmod 644 "$DESKTOP_ENTRY_PATH"

rm -rf "$TEMP_DOWNLOAD_DIR"

echo "✅ Cursor installed successfully! Run it with 'cursor' or from your applications menu."
