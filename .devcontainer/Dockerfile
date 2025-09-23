FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------
# 1) Core build deps for host (must be first)
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
 && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------
# 2) Sanity check: host gcc must work (clean PATH)
# ---------------------------------------------------------------------
RUN echo 'int main(){return 0;}' > /tmp/cc.c && \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    gcc /tmp/cc.c -o /tmp/cc && /tmp/cc

# ---------------------------------------------------------------------
# 3) Build Spike (uses host gcc, keep PATH clean)
# ---------------------------------------------------------------------
WORKDIR /tmp
RUN git clone https://github.com/riscv/riscv-isa-sim.git && \
    cd riscv-isa-sim && git submodule update --init --recursive && \
    mkdir build && cd build && \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    ../configure --prefix=/opt/riscv \
      || { echo '--- spike config.log ---'; cat config.log || true; exit 1; } && \
    make -j"$(nproc)" && make install

# ---------------------------------------------------------------------
# 4) Install prebuilt RISC-V GCC toolchain (cross compiler)
# ---------------------------------------------------------------------
WORKDIR /opt
RUN wget -q https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz \
 && tar -xzf riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz \
 && mv riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14 /opt/riscv \
 && rm -f *.tar.gz

# Add both bin dirs to PATH (host + cross)
ENV PATH="/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin:${PATH}"

# ---------------------------------------------------------------------
# 5) Build riscv-pk (proxy kernel) with cross toolchain
# ---------------------------------------------------------------------
WORKDIR /tmp
RUN set -eux; \
    export PATH="/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"; \
    which riscv64-unknown-elf-gcc; \
    riscv64-unknown-elf-gcc --version; \
    git clone https://github.com/riscv/riscv-pk.git; \
    cd riscv-pk; mkdir -p build; cd build; \
    CC=riscv64-unknown-elf-gcc \
    CXX=riscv64-unknown-elf-g++ \
    AR=riscv64-unknown-elf-ar \
    RANLIB=riscv64-unknown-elf-ranlib \
    ../configure --prefix=/opt/riscv --host=riscv64-unknown-elf \
      || { echo '--- pk config.log ---'; cat config.log || true; exit 1; }; \
    make -j"$(nproc)" V=1; \
    make install

# ---------------------------------------------------------------------
# 6) Clean up
# ---------------------------------------------------------------------
RUN rm -rf /tmp/*
WORKDIR /workspaces
