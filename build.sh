#!/bin/bash

if [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "Please check ANDROID_NDK_HOME directory"
    exit 1
fi

if [ -z "$ANDROID_NDK_HOME" ]; then
    echo "Please set your ANDROID_NDK_HOME environment variable first"
    exit 1
fi

if [[ "$ANDROID_NDK_HOME" == .* ]]; then
    echo "Please set your ANDROID_NDK_HOME to an absolute path"
    exit 1
fi

export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME
export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG

export CFLAGS="-Os"
export LDFLAGS="-Wl,-Bsymbolic"

chmod +x ./build-zlib.sh
chmod +x ./build-openssl.sh
chmod +x ./build-curl.sh

./build-zlib.sh
./build-openssl.sh
./build-curl.sh

exit 0
