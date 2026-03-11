# valkey-luajit

Valkey module to replace built-in Lua with LuaJIT.

## Build Preparation

```bash
git submodule update --init --recursive
```

## Build

```bash
./build.sh                    # Build module only
./build.sh --with-tests       # Build module and Valkey test server
./build.sh --clean            # Clean build artifacts
```

Module output: `build/libvalkeyluajit.so`

## Run Tests

```bash
# Build test infrastructure (first time only)
./build.sh --with-tests

# Run all tests
./tests/run-valkey-tests.sh

# Run specific tests
./tests/run-valkey-tests.sh --single unit/scripting
./tests/run-valkey-tests.sh --single unit/functions
```

## Module Loading

```bash
valkey-server --loadmodule build/libvalkeyluajit.so
```

Or in `valkey.conf`:
```
loadmodule build/libvalkeyluajit.so
```

## Enable FFI

FFI is disabled by default for security. To enable:

```bash
# In valkey.conf after loadmodule
luajit.enable-ffi-api yes
```
**WARNING**: FFI gives scripts unrestricted access to the process. This is NOT secure for untrusted scripts. Use only in trusted environments.

