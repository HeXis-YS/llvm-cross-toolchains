## LLVM Cross Toolchain

A single cross toolchain based on LLVM with multi architectures and platforms support.

Supported target platforms:

+ Linux: musl-libc, glibc

+ Android
+ Windows: MinGW, MSVC(Experiment)

+ Darwin: MacOSX, Mac-Catalyst, iOS, tvOS, watchOS

The toolchain itself works on Linux, Windows and MacOSX now.

### Build

#### Prerequisite tools and libs

+ GCC >= 5

+ CMake >= 3.0

+ Ninja

  It can be installed via `pip`:

  ```shell
  pip install ninja
  ```

+ Python 3

  > Python >= 3.8 is required on Windows to support unelevated symlinks with developer mode

+ Some development libs:

| Lib     | CentOS        | Ubuntu/Debian |
| ------- | ------------- | ------------- |
| libz    | zlib-devel    | zlib1g-dev    |
| liblzma | xz-devel      | liblzma-dev   |
| libxml2 | libxml2-devel | libxml2-dev   |

+ Windows host: 

    + MSYS2
    
    > NOTE: To build in MSYS2, you can install the following packages with `pacman`: 
    >
    > ```
    > curl rsync make patch
    > mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake mingw-w64-x86_64-ninja mingw-w64-x86_64-python3 mingw-w64-x86_64-zlib mingw-w64-x86_64-xz mingw-w64-x86_64-libxml2 mingw-w64-x86_64-polly
    > ```
    
    + Windows subsystem for Linux(WSL) with any Linux distribution(Optional)

#### Configure project

The file `version` contains the versions of some important toolchain components, such as LLVM, glibc, musl-libc and so on.

The array variable `CROSS_TARGETS` in the file `config` defines all cross target triples to be built.

You can change `version` and `config` based on your need.

#### Prepare stuff

##### Linux kernel header

> NOTE for MacOSX host: Linux kernel header must be built on Linux environment, it's recommended to build in Docker Linux image.

```shell
prebuilt-linux-header/build-linux-header.sh
```

##### Linux glibc

> NOTE: glibc must be built in glibc based Linux environment(eg. CentOS, Debian, Ubuntu).

Prerequisite development libs:

| Lib     | CentOS       | Ubuntu/Debian   |
| ------- | ------------ | --------------- |
| libgmp  | gmp-devel    | libgmp-dev      |
| libmpfr | mpfr-devel   | libmpfr-dev     |
| libmpc  | libmpc-devel | libmpc-dev      |


```shell
# Build glibc from source, it will take a long time
prebuilt-glibc/build-glibc.sh
```

##### Android Bionic libc

Prerequisite: Android NDK >= r21e

```shell
# Set the installation path of Android NDK
export ANDROID_NDK_HOME=/path/to/android-ndk
# Extract Bionic headers and libs from NDK
prebuilt-bionic/extract_bionic_from_ndk.sh
```

##### Darwin SDKs

**Method 1: (recommended)extract SDKs from installed XCode on MacOSX host**

1. Install gnu-tar, it can be installed via homebrew:

   ```shell
   brew install gnu-tar
   ```

   Check if command `gtar` is available.

2. Execute tool:

   ```shell
   prebuilt-darwin-sdk/extract_sdks_from_xcode.sh
   ```

3. Check and modify values of `MACOSX_VERSION`, `IOS_VERSION`, `APPLE_TVOS_VERSION`, `APPLE_WATCHOS_VERSION` in the file `version` to match those in XCode.

**Method 2: package SDKs manually**

1. Download SDKs from Internet or follow [here](https://github.com/tpoechtrager/osxcross#packaging-the-sdk) to package SDKs manually.

   Known download sources(may be invalid):

   + MacOSX SDK: [https://github.com/phracker/MacOSX-SDKs](https://github.com/phracker/MacOSX-SDKs)
   + iOS SDK: [https://github.com/xybp888/iOS-SDKs](https://github.com/xybp888/iOS-SDKs)

2. Create `.tar.xz` package for each SDK and rename them by name formats:
   + `MacOSX${MACOS_VERSION}.sdk.tar.xz` (for example, `MacOSX11.3.sdk.tar.xz`)
   + `iPhoneOS${IOS_VERSION}.sdk.tar.xz`, `iPhoneSimulator${IOS_VERSION}.sdk.tar.xz`
   + `AppleTVOS${APPLE_TVOS_VERSION}.sdk.tar.xz`, `AppleTVSimulator${APPLE_TVOS_VERSION}.sdk.tar.xz`
   + `WatchOS${APPLE_WATCHOS_VERSION}.sdk.tar.xz`, `WatchSimulator${APPLE_WATCHOS_VERSION}.sdk.tar.xz`
   
1. Put SDK packages in directory `prebuilt-darwin-sdk`.

##### Apple cctools

> NOTE for Windows host: cctools must be built in WSL.

Prerequisite:

+ clang >= 4
+ development libs:

| Lib     | CentOS       | Ubuntu/Debian   |
| ------- | ------------ | --------------- |
| llvm    | llvm-devel   | llvm-dev        |
| llvm(static libs) | llvm-static | llvm-dev |
| libuuid | libuuid-devel | uuid-dev     |
| openssl | openssl-devel | libssl-dev      |

Check if the following command works first:

```shell
llvm-config --link-static --libs lto
```

Build cctools:

```shell
./prebuilt-cctools/build-cctools.sh
```

#### Build and Assemble toolchain

Execute the script `build-all.sh` to start building.

```shell
./build-all.sh
```

The output directory path is defined by variable `OUTPUT_DIR` in the file `config`.

After building has finished successfully, you can use tool `strip_toolchain.sh` to strip the output toolchain.

### Project Reference

+ [llvm-mingw](https://github.com/mstorsjo/llvm-mingw)

+ [crosstool-ng](https://github.com/crosstool-ng/crosstool-ng)

+ [osxcross](https://github.com/tpoechtrager/osxcross)
