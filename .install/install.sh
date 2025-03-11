#!/bin/bash

### Variables
NAME="TPI"
AUTHOR="Thoq"
DATE="3-11-25"
INSTALL_DIR="$HOME/.local/bin/"
DOWNLOAD_DIR="/tmp/tpi/"
REPO=https://github.com/gleemers/tpi.git

### Welcome Screen
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "Welcome to the $NAME installer!"
echo "Written by $AUTHOR on $DATE"
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
### End Welcome Screen

### Download Portion Script
if ! command git -v > /dev/null; then
    echo "Git is not installed!"
fi

if ! command cargo -v > /dev/null; then
    echo "Cargo (Rust toolchain) is not installed!"
fi

if [ -d $DOWNLOAD_DIR ]; then
    echo "[-] tpi already installed!"
    echo "[*] Updating tpi..."
    cd $DOWNLOAD_DIR
    git pull
else
    if [ ! -d $DOWNLOAD_DIR ]; then
        mkdir -p $DOWNLOAD_DIR
    fi

    echo "[+] Downloading tpi ($DOWNLOAD_DIR)..."
    git clone https://github.com/gleemers/tpi.git $DOWNLOAD_DIR
fi

echo "[+] Entering dir: $DOWNLOAD_DIR"
cd $DOWNLOAD_DIR
### End Download Protion

### Installation Portion
echo "[+] Building tpi (this may take a while)..."
cargo build --release

echo "[+] Installing tpi to $INSTALL_DIR"
if [ ! -d $INSTALL_DIR ]; then
    mkdir -p $INSTALL_DIR
fi
mv $DOWNLOAD_DIR/target/release/tpi $INSTALL_DIR
### End Installation Portion

### Cleanup Portion
echo "To add to path, run:"
echo "==============================================="
echo "  export PATH=\"$HOME/.local/bin:$PATH\""
echo "==============================================="
echo
echo "Thank you!"
### End Cleanup Portion
