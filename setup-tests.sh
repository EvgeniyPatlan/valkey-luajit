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

# Apply all patches from tests/ directory
PATCHES_DIR="$SCRIPT_DIR/tests"
if compgen -G "$PATCHES_DIR/*.patch" > /dev/null; then
    echo ""
    echo "Applying patches..."
    for patch_file in "$PATCHES_DIR"/*.patch; do
        if [ -f "$patch_file" ]; then
            echo "  Applying: $(basename "$patch_file")"
            cd "$VALKEY_DIR"
            if patch -p1 --dry-run < "$patch_file" > /dev/null 2>&1; then
                patch -p1 < "$patch_file" || true
            else
                echo "    Patch already applied or not applicable, skipping"
            fi
        fi
    done
else
    echo "No patches found in $PATCHES_DIR"
fi

# Build Valkey without built-in Lua
echo ""
echo "Building Valkey server..."
cd "$VALKEY_DIR"
make BUILD_LUA=no -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo ""
echo "== Test setup complete! =="
echo "  Valkey binary:   $VALKEY_DIR/src/valkey-server"
echo "  Test runner:     $VALKEY_DIR/runtest"
echo ""
echo "Run tests:"
echo "  ./tests/run-valkey-tests.sh"
