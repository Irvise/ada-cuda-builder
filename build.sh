#!/usr/bin/env sh

# Repos and versions
GNAT_LLVM="https://github.com/AdaCore/gnat-llvm"
GCC="git://gcc.gnu.org/git/gcc.git"
CUDA="https://github.com/AdaCore/cuda"
LLVM_ADS="https://github.com/AdaCore/llvm-ads"
UWRAP="https://github.com/AdaCore/uwrap"
LANKIT="https://github.com/AdaCore/langkit"
LIB_ADALANG="https://github.com/AdaCore/libadalang"
BB_RUNTIMES="https://github.com/AdaCore/bb-runtimes"

# Setup
CWD=$PWD
ORIGINAL_PATH=$PATH
GNAT_LLVM_BIN=`command -v llvm-gcc`

# Builders
function build_llvm() {
    if [ -n "$GNAT_LLVM_BIN" ]; then
        echo "llvm-gcc binary is $GNAT_LLVM_BIN"
        echo "llvm-gcc found in \$PATH, not compiling!!!"
        return
    else
        echo "============ Building GNAT-LLVM ============"
        echo "============ Cloning  GNAT-LLVM ============"
        git clone --depth=1 $GNAT_LLVM
        cd gnat-llvm
        git clone --depth=1 $GCC llvm-interface/gcc
        ln -s gcc/gcc/ada llvm-interface/gnat_src
        git clone --depth=1 https://github.com/AdaCore/llvm-bindings.git

        echo "============ Pathcing GNAT-LLVM ============"
        git apply all-targets.patch

        echo "============ Compiling GNAT-LLVM ==========="
        make llvm

        echo "============ Adding   GNAT-LLVM ============"
        export PATH=$PWD/llvm-interface/bin:$PATH
        # Add the built LLVM installation as we will need the clang/llvm tools from here!
        export PATH=$PWD/llvm/llvm-obj/bin/:$PATH

        echo "============ Compiling  Bitcode ============"
        make gnatlib-bc || true
        cd $CWD
    fi
}

function build_auxiliary_tools_cuda () {
    cd $CWD
    echo "============ Building LLVM-ADS ============="
    git clone --depth=1 $LLVM_ADS
    cd llvm-ads
    make
    cp $PWD/bin/llvm-ads `dirname $GNAT_LLVM_BIN`
    
    echo "============ Building    UWRAP ============="
    echo "=========== Building UWRAP Deps ============"
    git clone --depth=1 $LANGKIT

    cd $CWD
    git clone --depth=1 $LIB_ADALANG
    
    echo "=== Finished building UWRAP dependencies ==="
    
    cd $CWD
    git clone --depth=1 $UWRAP
    cd uwrap

    cd lang_test
    make
    cd ../lang_template
    make
    cd ..
    source env.sh
    gprbuild

    export PATH=$PWD/obj:$PATH
    
    cd $CWD
}

function build_cuda () {
    echo "============ Starting Ada-CUDA ============="
    echo "============ Cloning auxiliary ============="
    cd $CWD
    git clone --depth=1 $BB_RUNTIMES
    git clone --depth=1 $GCC
    

    echo "============ Building auxiliary ============="
    
    build_auxiliary_tools_cuda

    echo "============ Building  Ada-CUDA ============="
    cd $CWD
    git clone --depth=1 $CUDA
    cd cuda
    
    echo "============ Building  Wrapper ============="
    make -f wrapper-Makefile

    
}

# Main flow

build_llvm
build_cuda
