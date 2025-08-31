#!/usr/bin/env bash
set -euo pipefail

APP_NAME="debian-nvidia-installer"
VERSION="$(cat ./VERSION)"
BUILD_DIR="deb_build"

# Remove previous builds
rm -rf "$BUILD_DIR"
mkdir "$BUILD_DIR"

# Copy package files
cp -r "./DEBIAN" "$BUILD_DIR/"
cp -r "./usr" "$BUILD_DIR/"

# Apply version to control file
sed -i "s/^Version:.*$/Version: ${VERSION}/" "$BUILD_DIR/DEBIAN/control"

# Apply version to main script file
sed -i "s/^declare -g SCRIPT_VERSION=\"[^\"]*\"/declare -g SCRIPT_VERSION=\"${VERSION}\"/" "$BUILD_DIR/usr/bin/debian-nvidia-installer"

# Build DEB package
DEB_FILE="${APP_NAME}_${VERSION}_amd64.deb"
dpkg-deb --build --root-owner-group "$BUILD_DIR" "$BUILD_DIR/$DEB_FILE"

echo "Created DEB package: $BUILD_DIR/$DEB_FILE"
