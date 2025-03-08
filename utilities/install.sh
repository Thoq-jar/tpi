#!/bin/bash

set -e pipefail
NAME="tpi"
VERSION="1.1.0"
INSTALL_DIR="$HOME/.local/bin"
AUTHOR="Thoq"
DATE="MAR-8-2025"

# This script is used to install the application.

echo "Welcome to the $NAME installer!"
echo "Written by $AUTHOR @ $DATE"
echo "Installing $NAME v$VERSION..."

if ! command -v git > /dev/null; then
    echo "Error: git is not installed!"
    exit 1
fi

if ! command -v gleam > /dev/null; then
    echo "Error: gleam is not installed!"
    exit 1
fi

echo "Starting in 3s..."
sleep 3

echo ""
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"

echo "Downloading $NAME..."
git clone https://github.com/gleemers/tpi.git /tmp/tpi

cd /tmp/tpi

echo "Building $NAME..."
./utilities/package.sh

echo "Creating install directory $INSTALL_DIR..."
mkdir -p $INSTALL_DIR

echo "Copying files to $INSTALL_DIR..."
cp -r /tmp/tpi/$NAME-$VERSION.tar.gz $INSTALL_DIR
cd $INSTALL_DIR

echo "Extracting $NAME-$VERSION.tar.gz..."
tar -xzf $NAME-$VERSION.tar.gz
mv "$NAME"_bundle $NAME

echo "Cleaning up..."
rm -rf /tmp/tpi
rm $NAME-$VERSION.tar.gz


echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo ""

echo "Installation complete!"
echo "To add to path run:"
echo "export PATH=\$PATH:$INSTALL_DIR/$NAME"
echo "Or add the above line to your shell profile. (e.g. ~/.bashrc, ~/.zshrc)"
echo "To uninstall, simply remove the $INSTALL_DIR/$NAME directory."

echo "Thank you!"
