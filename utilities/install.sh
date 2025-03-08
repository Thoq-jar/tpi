#!/bin/bash

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

echo "Checking for existing $NAME installation..."
if [ -d $INSTALL_DIR/$NAME ]; then
    echo "$NAME is already installed, checking for updates..."
    rm -rf $INSTALL_DIR/$NAME
fi

echo "Downloading $NAME..."
git clone https://github.com/gleemers/tpi.git /tmp/tpi

cd /tmp/tpi

echo "Building $NAME..."
### BUILD SCRIPT
set -e pipefail
NAME="tpi"
VERSION="1.1.0"
BUNDLE_DIR="$NAME"_bundle
INTERNAL_DIR=_internal
TARBALL="$NAME-$VERSION.tar.gz"
AUTHOR="Thoq"
DATE="MAR-8-2025"
# This script is used to package the application for distribution.

echo "Welcome to the $NAME bundler!"
echo "Written by $AUTHOR @ $DATE"
echo "Bundling $NAME v$VERSION..."

echo ""
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo "Removing old bundle $BUNDLE_DIR in 1s..."
sleep 1

if [ -d $BUNDLE_DIR ]; then
    rm -rf $BUNDLE_DIR
fi

echo "Removing old $NAME in 1s..."
sleep 1
if [ -d $NAME ]; then
    rm -rf $NAME
fi

echo "Creating new bundle $BUNDLE_DIR..."
mkdir -p $BUNDLE_DIR

echo "Testing $NAME..."
if ! gleam test > /dev/null; then
    echo "Error: $NAME tests failed!"
    exit 1
fi

echo "Building $NAME..."
if ! gleam export erlang-shipment > /dev/null; then
    echo "Error: Failed to build $NAME"
    exit 1
fi

echo "Creating $NAME/$INTERNAL_DIR..."
mkdir -p $NAME/$INTERNAL_DIR

echo "Copying files to $NAME/$INTERNAL_DIR..."
mv build/erlang-shipment/ ./$NAME/$INTERNAL_DIR

echo "Writing launcher..."
cat << 'EOF' > ./$NAME/$NAME
#!/bin/bash
$(dirname "$0")/_internal/erlang-shipment/entrypoint.sh run "$@"
EOF

echo "Making launcher executable..."
chmod +x ./$NAME/$NAME

mv ./$NAME $BUNDLE_DIR

echo "Creating tarball... ($TARBALL)"
tar -czf $TARBALL $BUNDLE_DIR/$NAME

echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo ""

echo "Bundling complete!"
### END BUILD SCRIPT

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
echo "=============================================================="
echo "  export PATH=\$PATH:$INSTALL_DIR/$NAME/$NAME"
echo "=============================================================="
echo "Or add the above line to your shell profile. (e.g. ~/.bashrc, ~/.zshrc)"
echo "To uninstall, simply remove the $INSTALL_DIR/$NAME/$NAME directory."

echo "Thank you!"
