FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Base dependencies
RUN apt-get update && apt-get install -y \
    git curl wget ca-certificates vim \
    build-essential gcc g++ make pkg-config \
    autoconf automake autotools-dev libtool \
    bison flex texinfo gperf patchutils \
    gawk libmpc-dev libmpfr-dev libgmp-dev \
    zlib1g-dev libexpat1-dev \
    device-tree-compiler libfdt-dev \
    python3 iverilog gtkwave \
    libpixman-1-dev libglib2.0-dev \
 && rm -rf /var/lib/apt/lists/*

ARG MAKE_JOBS
ENV MAKE_JOBS=${MAKE_JOBS:-$(nproc)}
ENV RISCV=/opt/riscv
ENV PATH="${RISCV}/bin:${PATH}"

# Sanity check
RUN echo 'int main(){return 0;}' > /tmp/cc.c && gcc /tmp/cc.c -o /tmp/cc && /tmp/cc

# Build spike
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/riscv/riscv-isa-sim.git && \
    cd riscv-isa-sim && \
    mkdir build && cd build && \
    ../configure --prefix=${RISCV} && \
    make -j"${MAKE_JOBS}" && make install && \
    cd /tmp && rm -rf riscv-isa-sim

# Build toolchain
WORKDIR /tmp
RUN git clone --depth 1 --recursive https://github.com/riscv-collab/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain && \
    mkdir build && cd build && \
    ../configure --prefix=${RISCV} --with-arch=rv64imac --with-abi=lp64 && \
    make -j"${MAKE_JOBS}" newlib && \
    cd /tmp && rm -rf riscv-gnu-toolchain

# Build riscv-pk
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/riscv/riscv-pk.git && \
    cd riscv-pk && mkdir build && cd build && \
    ../configure --prefix=${RISCV} --host=riscv64-unknown-elf && \
    make -j"${MAKE_JOBS}" && make install && \
    cd /tmp && rm -rf riscv-pk

WORKDIR /workspaces
