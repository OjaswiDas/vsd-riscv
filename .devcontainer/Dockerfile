FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------
# 1) Core build deps + utilities (same as you already had)
# ---------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    git curl wget ca-certificates vim \
    build-essential gcc g++ make pkg-config \
    autoconf automake autotools-dev libtool \
    bison flex texinfo gperf patchutils \
    gawk libmpc-dev libmpfr-dev libgmp-dev \
    zlib1g-dev libexpat1-dev \
    device-tree-compiler libfdt-dev \
    python3 iverilog gtkwave \
    # Spike deps:
    libboost-regex-dev libboost-system-dev \
 && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------
# 2) Prebuilt RISC-V GCC (your original choice)
# ---------------------------------------------------------------------
WORKDIR /opt
RUN wget -q https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz \
 && tar -xzf riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz \
 && mv riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14 /opt/riscv \
 && rm -f *.tar.gz

# Cross toolchain on PATH for general use (we will override PATH for Spike build)
ENV PATH="/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin:${PATH}"

# Sanity: host compiler must still work (detect PATH issues early)
RUN echo 'int main(){return 0;}' > /tmp/cc.c && gcc /tmp/cc.c -o /tmp/cc && /tmp/cc

# ---------------------------------------------------------------------
# 3) Spike (host build) — use CLEAN host PATH to avoid picking cross binutils
# ---------------------------------------------------------------------
WORKDIR /tmp
RUN set -eux; \
    export CLEAN_PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"; \
    git clone --depth 1 https://github.com/riscv-software-src/riscv-isa-sim.git; \
    cd riscv-isa-sim; \
    git submodule update --init --recursive; \
    mkdir -p build; cd build; \
    PATH="$CLEAN_PATH" ../configure --prefix=/opt/riscv \
      || { echo '--- spike config.log ---'; cat config.log || true; exit 1; }; \
    PATH="$CLEAN_PATH" make -j"$(nproc)"; \
    make install; \
    rm -rf /tmp/*

# ---------------------------------------------------------------------
# 4) Proxy Kernel (riscv-pk) — cross-compile; pin to v1.0.0 for 2019 toolchain
# ---------------------------------------------------------------------
WORKDIR /tmp
RUN set -eux; \
    export CROSS_PATH="/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin:$PATH"; \
    git clone https://github.com/riscv-software-src/riscv-pk.git; \
    cd riscv-pk; \
    git checkout v1.0.0; \
    mkdir -p build; cd build; \
    PATH="$CROSS_PATH" \
    CC=riscv64-unknown-elf-gcc \
    CXX=riscv64-unknown-elf-g++ \
    AR=riscv64-unknown-elf-ar \
    RANLIB=riscv64-unknown-elf-ranlib \
    ../configure --prefix=/opt/riscv --host=riscv64-unknown-elf \
      || { echo '--- pk config.log ---'; cat config.log || true; exit 1; }; \
    PATH="$CROSS_PATH" make -j"$(nproc)" V=1; \
    make install; \
    rm -rf /tmp/*

# ---------------------------------------------------------------------
# 5) Default workspace
# ---------------------------------------------------------------------
WORKDIR /workspaces
