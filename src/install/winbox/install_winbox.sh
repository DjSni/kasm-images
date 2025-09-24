#!/usr/bin/env bash
set -ex

# Install Signal
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')
if [ "${ARCH}" == "arm64" ] ; then
    echo "Signal for arm64 currently not supported, skipping install"
    exit 0
fi

# Set VARS
DOWNLOAD_URL=$(wget --https-only -qO- https://mikrotik.com/download | grep -oP '<li><a href="\K[^"]+(?=.*Linux)')
WINBOX_DIR="winbox4"
WINBOX_INSTALL_DIR="/opt/$WINBOX_DIR"
SYMLINK_PATH="/usr/local/bin/winbox"
DESKTOP_FILE_PATH="/usr/share/applications/winbox4.desktop"
DOWNLOAD_DIR=/tmp

# Install requirements
apt update && apt -y upgrade
apt -y install unzip libxkbcommon-x11-0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0-dev

# Check if /opt exist
if [ ! -d /opt ]; then
  mkdir -p /opt
fi

# Download
cd "$DOWNLOAD_DIR"
wget "$DOWNLOAD_URL" -O WinBox_Linux.zip

# Unpack and move
unzip WinBox_Linux.zip -d "$WINBOX_DIR"

mv "$WINBOX_DIR" "$WINBOX_INSTALL_DIR"

# Remove
rm WinBox_Linux.zip

# Create symlink
ln -s "$WINBOX_INSTALL_DIR/WinBox" "$SYMLINK_PATH"

# Create desktop entry
cat > "$DESKTOP_FILE_PATH" <<EOL
[Desktop Entry]
Type=Application
Name=WinBox4
Icon=$WINBOX_INSTALL_DIR/assets/img/winbox.png
Exec=$WINBOX_INSTALL_DIR/WinBox
Comment=Mikrotik WinBox GUI for Router Management
Categories=Network;System;
EOL
cp $DESKTOP_FILE_PATH $HOME/Desktop/

# chown
chmod +x $HOME/Desktop/winbox4.desktop
chmod -R 777 $WINBOX_INSTALL_DIR
chmod 777 $SYMLINK_PATH

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi