# ada-cuda-builder

WARNING: This repository is currently unfinished and broken!!

This repository contains the automatic building system for GNAT-LLVM and Ada-CUDA.

## Requirements

- An installation of GNAT (GCC-Ada) v15 or newer is needed. 
- GPRbuild is also required. 
- Git is mandatory as the script will be pulling some repositories.
- CMake and make are mandatory for GNAT-LLVM build.
- Of course, a CUDA toolchain, v13 is recommended.

## What does this script do?

1. It builds the GNAT-LLVM compiler (all of LLVM!! so it will take a while!) if it cannot detect one in the path already. If you have it already built, please, ensure that the `nvptx` target is available. You can list available targets using `clang -print-targets`
2. It will then build the Ada-CUDA bindings. This will also build all necessary tools that are needed for this, such as `llvm-ads` and `uwrap`.

## How to run it?

Run the `build.sh` file. Please, read it, as it is never a good practice to run unverified shell files in your computer.
