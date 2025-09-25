set -x
# 目标HarmonyOS版本
# 编译arm64-v8a 配置CPU为aarch64
# 编译armeabi-v7a 配置CPU为arm
CPU=aarch64
#so库输出目录
OUTPUT=$(pwd)/harmonyos/$CPU
OH_SDK=$(dirname)/ohos-sdk/linux
# 编译环境
SYSROOT=$OH_SDK/native/sysroot
CC=$OH_SDK/native/llvm/bin/$CPU-linux-ohos-clang
STRIP=$OH_SDK/native/llvm/bin/llvm-strip
LD=$OH_SDK/native/llvm/bin/$CPU-linux-ohos-clang
OPTIMIZE_CFLAGS="-march=$CPU"
HOST_CC=/usr/bin/clang
HOST_LD=/usr/bin/clang
HOST_LD_FLAG=-L/usr/lib/x86_64-linux-gnu
function build
{
  ./configure \
  --prefix=$OUTPUT \
  --target-os=linux \
  --cpu=$CPU \
  --disable-asm \
  --enable-cross-compile \
  --disable-x86asm \
  --enable-shared \
  --enable-static \
  --disable-doc \
  --disable-htmlpages \
  --disable-optimizations \
  --cc=$CC \
  --ld=$LD \
  --strip=$STRIP \
  --sysroot=$SYSROOT \
  --host-cc=$HOST_CC \
  --host-ld=$HOST_LD \
  --host-os=linux \
  --host-ldflags=$HOST_LD_FLAG \
  --extra-cflags="-Os -fpic" \
  --disable-vulkan \
  --disable-stripping

  make clean all
# 这里是定义用几个CPU编译
  make -j8
  make install
}
build
