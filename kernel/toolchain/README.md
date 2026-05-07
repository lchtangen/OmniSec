# Kernel Toolchain Setup

## OnePlus 7 Pro (guacamole) - LineageOS 23.2 / Android 16

### Quick Install

```bash
sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
```

### Verify

```bash
aarch64-linux-gnu-gcc --version
aarch64-linux-gnu-objdump --version
```

### Alternative: Android NDK Toolchain

```bash
# Download NDK
wget https://dl.google.com/android/repository/android-ndk-r27-linux.zip
unzip android-ndk-r27-linux.zip

# Use NDK's standalone toolchain
export PATH="$PWD/android-ndk-r27/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
export CROSS_COMPILE=aarch64-linux-android-
```

### Kernel Source

```bash
git clone --depth=1 https://github.com/LineageOS/android_kernel_oneplus_sm8150.git
```

### Build

```bash
cd kernel
./build-kernel.sh all
```
