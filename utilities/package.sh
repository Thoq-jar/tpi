#!/bin/bash

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
set -e pipefail
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
