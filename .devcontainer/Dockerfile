# Use a suitable base image, for example, a recent Ubuntu release
FROM ubuntu:22.04

# Set environment variables for RISC-V installation path
ENV RISCV=/opt/riscv

# Install necessary build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libtool \
    autoconf \
    automake \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    gawk \
    flex \
    bison \
    texinfo \
    patch \
    zlib1g-dev \
    libexpat-dev \
    pkg-config \
    iverilog \
    gtkwave

# Clone and build riscv-gnu-toolchain
WORKDIR /tmp
RUN git clone https://github.com/riscv-software-src/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain && \
    ./configure --prefix=$RISCV --with-arch=rv64gc --with-abi=lp64d && \
    make -j$(nproc) && \
    make install

# Clone and build Spike (RISC-V ISA Simulator)
WORKDIR /tmp
RUN git clone https://github.com/riscv-software-src/riscv-isa-sim.git && \
    mkdir riscv-isa-sim/build && \
    cd riscv-isa-sim/build && \
    ../configure --prefix=$RISCV --with-varch=vlen:256,elen:64 --with-isa=rv64gcv --with-target=riscv64-unknown-elf && \
    make -j$(nproc) && \
    make install

# Clone and build Proxy Kernel (PK)
WORKDIR /tmp
RUN git clone https://github.com/riscv-software-src/riscv-pk.git && \
    mkdir riscv-pk/build && \
    cd riscv-pk/build && \
    ../configure --prefix=$RISCV --host=riscv64-unknown-elf && \
    make -j$(nproc) && \
    make install

# Add RISC-V binaries to PATH
ENV PATH=$PATH:$RISCV/bin:$RISCV/riscv64-unknown-elf/bin

# Clean up build directories to reduce image size
RUN rm -rf /tmp/*

# Set default command (optional, can be adjusted based on usage)
CMD ["bash"]
