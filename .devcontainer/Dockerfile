FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 0) Base build deps
RUN apt-get update && apt-get install -y \
    git curl wget ca-certificates vim \
    build-essential gcc g++ make pkg-config \
    autoconf automake autotools-dev libtool \
    bison flex texinfo gperf patchutils \
    gawk libmpc-dev libmpfr-dev libgmp-dev \
    zlib1g-dev libexpat1-dev \
    device-tree-compiler libfdt-dev \
    python3 iverilog gtkwave \
 && rm -rf /var/lib/apt/lists/*

ARG MAKE_JOBS
ENV MAKE_JOBS=${MAKE_JOBS:-$(nproc)}

# 1) Sanity: host gcc must work
RUN echo 'int main(){return 0;}' > /tmp/cc.c && gcc /tmp/cc.c -o /tmp/cc && /tmp/cc

# 3) riscv-gnu-toolchain (bare-metal newlib)
WORKDIR /tmp
RUN git clone --depth 1 --recursive https://github.com/riscv-collab/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain && \
    git submodule update --init --recursive --depth 1 && \
    mkdir build && cd build && \
    ../configure --prefix=/opt/riscv --with-arch=rv64imac --with-abi=lp64 && \
    make -j"${MAKE_JOBS}" newlib

ENV PATH="/opt/riscv/bin:${PATH}"

RUN rm -rf /tmp/*
WORKDIR /workspaces
