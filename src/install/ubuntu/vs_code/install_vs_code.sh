#!/usr/bin/env bash
set -ex
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/x64/g')
wget -q https://update.code.visualstudio.com/latest/linux-deb-${ARCH}/stable -O vs_code.deb
apt-get update
apt-get install -y ./vs_code.deb
mkdir -p /usr/share/icons/hicolor/apps
wget -O /usr/share/icons/hicolor/apps/vscode.svg https://kasm-static-content.s3.amazonaws.com/icons/vscode.svg
code_desktop=$(find /usr/share/applications -maxdepth 1 -name 'code*.desktop' -print -quit)
if [ -z "$code_desktop" ]; then
    echo "VS Code desktop entry not found under /usr/share/applications" >&2
    exit 1
fi
sed -i '/Icon=/c\Icon=/usr/share/icons/hicolor/apps/vscode.svg' "$code_desktop"
sed -i 's#/usr/share/code/code#/usr/share/code/code --no-sandbox##' "$code_desktop"
cp "$code_desktop" "$HOME/Desktop/code.desktop"
chmod +x "$HOME/Desktop/code.desktop"
chown 1000:1000 "$HOME/Desktop/code.desktop"
rm vs_code.deb

# Conveniences for python development
apt-get update
apt-get install -y python3-setuptools \
                   python3-venv \
                   python3-virtualenv

# Cleanup
apt-get autoclean
rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
