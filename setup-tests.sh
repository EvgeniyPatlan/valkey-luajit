#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
VALKEY_VERSION="${SERVER_VERSION:-unstable}"
VALKEY_DIR="$BUILD_DIR/valkey"

echo "== Setting up Valkey test infrastructure =="
echo "  Version: $VALKEY_VERSION"

# Download Valkey if not present
if [ ! -d "$VALKEY_DIR" ]; then
    echo ""
    echo "Downloading Valkey $VALKEY_VERSION..."
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    git clone https://github.com/valkey-io/valkey.git valkey
    cd valkey
    git checkout "$VALKEY_VERSION"
else
    echo "Valkey already downloaded at $VALKEY_DIR"
fi

# Build Valkey without built-in Lua
echo ""
echo "Building Valkey server..."
cd "$VALKEY_DIR"
make BUILD_LUA=no -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Copy custom test files to Valkey test directory
echo ""
echo "Copying custom tests..."
if [ -d "$SCRIPT_DIR/tests" ] && [ -n "$(ls -A $SCRIPT_DIR/tests/*.tcl 2>/dev/null)" ]; then
    cp "$SCRIPT_DIR/tests/"*.tcl "$VALKEY_DIR/tests/unit/"
    echo "  Custom tests copied to $VALKEY_DIR/tests/unit/"
else
    echo "  No custom test files found in $SCRIPT_DIR/tests/"
fi

echo ""
echo "== Test setup complete! =="
echo "  Valkey binary:   $VALKEY_DIR/src/valkey-server"
echo "  Test runner:     $VALKEY_DIR/runtest"
echo ""
echo "Run tests:"
echo "  ./tests/run-valkey-tests.sh"
