#!/bin/bash

set -e

echo "Setting up RISC-V Toolchain..."

# Store current directory
pwd=$PWD

# Create directories
mkdir -p $HOME/riscv_toolchain
cd $HOME/riscv_toolchain

# Install system dependencies
sudo apt-get update
sudo apt-get install -y \
    autoconf \
    automake \
    autotools-dev \
    curl \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    gawk \
    build-essential \
    bison \
    flex \
    texinfo \
    gperf \
    libtool \
    patchutils \
    bc \
    zlib1g-dev \
    libexpat1-dev \
    gtkwave \
    device-tree-compiler

# Download and install RISC-V GCC toolchain
if [ ! -d "riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14" ]; then
    wget "https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz"
    tar -xvzf riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz
    rm riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz
fi

# Add to PATH
echo "export PATH=\$HOME/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:\$PATH" >> $HOME/.bashrc
export PATH=$HOME/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:$PATH

# Build and install Spike (RISC-V ISA Simulator)
if [ ! -d "riscv-isa-sim" ]; then
    git clone https://github.com/riscv/riscv-isa-sim.git
    cd riscv-isa-sim/
    mkdir build
    cd build
    ../configure --prefix=$HOME/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14
    make -j$(nproc)
    sudo make install
fi

cd $HOME/riscv_toolchain

# Build and install RISC-V Proxy Kernel (pk)
if [ ! -d "riscv-pk" ]; then
    git clone https://github.com/riscv/riscv-pk.git
    cd riscv-pk/
    mkdir build
    cd build/
    ../configure --prefix=$HOME/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14 --host=riscv64-unknown-elf
    make -j$(nproc)
    sudo make install
fi

cd $HOME/riscv_toolchain

# Build and install Icarus Verilog (iverilog)
if [ ! -d "iverilog" ]; then
    git clone https://github.com/steveicarus/iverilog.git
    cd iverilog/
    git checkout --track -b v10-branch origin/v10-branch
    git pull
    chmod +x autoconf.sh
    ./autoconf.sh
    ./configure
    make -j$(nproc)
    sudo make install
fi

# Source the bashrc to make tools available immediately
source $HOME/.bashrc

# Create a test directory with sample files
cd $pwd
mkdir -p examples
cat > examples/hello.c << 'EOF'
#include <stdio.h>

int main() {
    printf("Hello, RISC-V!\\n");
    return 0;
}
EOF

cat > examples/test.asm << 'EOF'
# Simple RISC-V assembly test
.section .text
.global _start
_start:
    li a0, 0
    li a7, 93
    ecall
EOF

echo "RISC-V Toolchain setup completed successfully!"
echo "Tools available:"
echo "- riscv64-unknown-elf-gcc"
echo "- spike (RISC-V simulator)"
echo "- pk (proxy kernel)"
echo "- iverilog"
echo ""
echo "Try compiling: riscv64-unknown-elf-gcc examples/hello.c -o hello.elf"
echo "Try simulating: spike pk hello.elf"
