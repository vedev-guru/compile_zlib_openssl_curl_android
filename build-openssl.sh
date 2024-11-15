#!/bin/bash
if [ -f /proc/cpuinfo ]; then
    JOBS=$(grep flags /proc/cpuinfo | wc -l)
elif [ ! -z $(which sysctl) ]; then
    JOBS=$(sysctl -n hw.ncpu)
else
    JOBS=2
fi

PATH=$TOOLCHAIN/bin:$PATH

mkdir -p ./build/openssl
export BUILD_FOLDER=$PWD/build/openssl
cd openssl

export AR=$TOOLCHAIN/bin/llvm-ar
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip
export TARGET_HOST=(aarch64-linux-android armv7a-linux-androideabi x86_64-linux-android i686-linux-android)
export ANDROID_ARCH=(arm64-v8a armeabi-v7a x86_64 x86)
export OPENSSL_TARGET_HOST=(android-arm64 android-arm android-x86_64 android-x86)

# Apply patch that fixes the armcap instruction
# Linux version
sed -e '/[.]hidden.*OPENSSL_armcap_P/d; /[.]extern.*OPENSSL_armcap_P/ {p; s/extern/hidden/ }' -i -- crypto/*arm*pl crypto/*/asm/*arm*pl
# macOS version
# sed -E -i '' -e '/[.]hidden.*OPENSSL_armcap_P/d' -e '/[.]extern.*OPENSSL_armcap_P/ {p; s/extern/hidden/; }' crypto/*arm*pl crypto/*/asm/*arm*pl

index=0

for target in ${TARGET_HOST[*]}; do
    export CC=$TOOLCHAIN/bin/$target$MIN_SDK_VERSION-clang
    export AS=$CC
    export CXX=$TOOLCHAIN/bin/$target$MIN_SDK_VERSION-clang++

    mkdir -p $BUILD_FOLDER/${ANDROID_ARCH[index]}

    ./Configure \
        ${OPENSSL_TARGET_HOST[index]} \
        -D__ANDROID_API__=$MIN_SDK_VERSION \
        -fPIC \
        --prefix=$BUILD_FOLDER/${ANDROID_ARCH[index]}

    make -j$JOBS
    make install
    make clean
    index=$(($index + 1))
done

cd ..
