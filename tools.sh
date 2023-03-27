#!/bin/bash

function apply_patch {
    if [ -d "$PATCH_DIR/$1" ]; then
        for patchfile in "$PATCH_DIR/$1/"*.patch; do
            patch -p1 < "$patchfile"
        done
    fi
}

function check_build_for_targets {
    for target in "${CROSS_TARGETS[@]}"; do
        if [[ $target == *"$1"* ]]; then
            return 0
        fi
    done
    return 1
}

function cpu_count {
    if [[ $BUILD_HOST == "Darwin" ]]; then
        NCPU="$(sysctl -n hw.logicalcpu)"
    else
        NCPU="$(nproc)"
    fi
    if [ -n "$SAVE_CPU" ]; then
        NCPU=`expr $NCPU / 2`
    fi
    echo "$NCPU"
}

function target_install_prefix {
    if [[ "$1" == *"mingw"* || "$1" == *"windows"* || "$1" == "wasm"* ]]; then
        echo "$OUTPUT_DIR/$1"
    else
        echo "$OUTPUT_DIR/$1/usr"
    fi
}

function target_install_libdir_suffix {
    if [[ "$1" == "wasm32"* && "$1" == *"wasi"* ]]; then
        if [[ "$1" == *"threads"* ]]; then
            echo "/wasm32-wasi-threads"
        else
            echo "/wasm32-wasi"
        fi
    elif [[ "$1" == "wasm64"* && "$1" == *"wasi"* ]]; then
        if [[ "$1" == *"threads"* ]]; then
            echo "/wasm64-wasi-threads"
        else
            echo "/wasm64-wasi"
        fi
    else
        echo ""
    fi
}

function go_build {
    go mod tidy
    goos=""
    goarch=""
    case "$CROSS_PREFIX" in
    *linux*)
        goos=linux
        ;;
    *darwin*|*macos*|*apple*)
        goos=darwin
        ;;
    *mingw*|*windows*)
        goos=windows
        ;;
    esac
    case "$CROSS_PREFIX" in
    x86_64*)
        goarch=amd64
        ;;
    i*86*)
        goarch=386
        ;;
    aarch64*|arm64*)
        goarch=arm64
        ;;
    esac
    GOOS=$goos GOARCH=$goarch go build "$@"
}
