#!/bin/bash

set -e

function print_usage() {
cat<<EOF
Usage: build.sh [--release] [--clean]

    --help | -h               Print this help message and exit.
    --release                 Builds the release configuration (default).
    --clean                   Cleans the build artifacts.
    --with-tests              Also build Valkey test server (needed for ./tests/run-valkey-tests.sh).

Example usage:

    # Build the release configuration (module only)
    ./build.sh --release

    # Build module and Valkey test server
    ./build.sh --with-tests

    # Clean build artifacts
    ./build.sh --clean

EOF
}

SCRIPT_DIR=$(pwd)
BUILD_DIR="$SCRIPT_DIR/build"
BUILD_RELEASE=1
CLEAN_BUILD=0
BUILD_TESTS=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    arg="$1"
    case $arg in
        --release)
            BUILD_RELEASE=1
            shift
            ;;
        --clean)
            CLEAN_BUILD=1
            shift
            ;;
        --with-tests)
            BUILD_TESTS=1
            shift
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            print_usage
            exit 1
            ;;
    esac
done

if [ $CLEAN_BUILD -eq 1 ]; then
    echo "Cleaning build artifacts..."
    
    # Check if LuaJIT build artifacts exist
    LUAJIT_SRC_DIR="$SCRIPT_DIR/deps/luajit/src"
    if [ ! -f "$LUAJIT_SRC_DIR/luajit" ] && \
       [ ! -f "$LUAJIT_SRC_DIR/libluajit.a" ] && \
       [ ! -f "$LUAJIT_SRC_DIR/libluajit.so" ]; then
        echo "LuaJIT artifacts not present, already clean"
    else
        # CMake configuration needed for luajit_clean target
        if [ ! -f "$BUILD_DIR/Makefile" ] && [ ! -f "$BUILD_DIR/CMakeCache.txt" ]; then
            echo "CMake configuration not found, running configuration..."
            mkdir -p "$BUILD_DIR"
            cd "$BUILD_DIR"
            cmake .. -DCMAKE_BUILD_TYPE=Release
            cd "$SCRIPT_DIR"
        fi
        
        # Clean LuaJIT artifacts using CMake target
        echo "Cleaning LuaJIT build..."
        cmake --build "$BUILD_DIR" --target luajit_clean
    fi
    
    # Clean main build directory
    rm -rf "$BUILD_DIR"
    
    echo "Clean completed"
    exit 0
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Set default valkey version if not specified
if [ -z "$SERVER_VERSION" ]; then
    echo "SERVER_VERSION not set, defaulting to 'unstable'"
    export SERVER_VERSION="unstable"
fi

# Set CMake flags
CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release"

echo "Configuring with: $CMAKE_FLAGS"
cmake .. $CMAKE_FLAGS

echo "Building..."
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

if [ $BUILD_TESTS -eq 1 ]; then
    echo ""
    echo "Building Valkey test server..."
    "$SCRIPT_DIR/setup-tests.sh"
fi

echo ""
echo "Build complete!"
echo ""
echo "Module location: $BUILD_DIR/libvalkeyluajit.so"
if [ $BUILD_TESTS -eq 1 ]; then
    echo "Valkey test server: $BUILD_DIR/valkey/src/valkey-server"
    echo ""
    echo "To run valkey tests with luajit module:"
    echo "  ./tests/run-valkey-tests.sh"
    echo ""
    echo "Examples:"
    echo "  ./tests/run-valkey-tests.sh --single unit/scripting"
    echo "  ./tests/run-valkey-tests.sh --single unit/functions"
else
    echo ""
    echo "To build test infrastructure:"
    echo "  ./build.sh --with-tests"
    echo "  Or run separately: ./setup-tests.sh"
fi
