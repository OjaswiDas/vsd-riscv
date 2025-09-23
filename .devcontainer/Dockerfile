FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Core build deps FIRST
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

# --- Sanity: host compiler must work (use a clean PATH) ---
RUN echo 'int main(){return 0;}' > /tmp/cc.c && \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" gcc /tmp/cc.c -o /tmp/cc && /tmp/cc

# --- Spike (host build; keep PATH clean) ---
WORKDIR /tmp
RUN git clone https://github.com/riscv/riscv-isa-sim.git && \
    cd riscv-isa-sim && git submodule update --init --recursive && \
    mkdir build && cd build && \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    ../configure --prefix=/opt/riscv || { echo '--- spike config.log ---'; cat config.log || true; exit 1; } && \
    make -j"$(nproc)" && make install

# --- Proxy kernel (host builds cross-ELF via the cross GCC later) ---
# We can configure pk now with --host after the cross toolchain is exposed to PATH,
# but to keep the order clean we’ll install the cross toolchain first and then build pk.

# --- Install RISC-V GCC (cross toolchain), *after* Spike ---
WORKDIR /opt
RUN wget -q https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz \
 && tar -xzf riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz \
 && mv riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14 /opt/riscv \
 && rm -f *.tar.gz

# Expose cross toolchain only now (prevents host gcc from seeing cross 'as')
ENV PATH="/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin:${PATH}"

# --- Now build riscv-pk using the cross toolchain ---
WORKDIR /tmp
RUN git clone https://github.com/riscv/riscv-pk.git && \
    cd riscv-pk && mkdir build && cd build && \
    CC=riscv64-unknown-elf-gcc \
    CXX=riscv64-unknown-elf-g++ \
    AR=riscv64-unknown-elf-ar \
    RANLIB=riscv64-unknown-elf-ranlib \
    ../configure --prefix=/opt/riscv --host=riscv64-unknown-elf \
      || { echo '--- pk config.log ---'; cat config.log || true; exit 1; } && \
    make -j"$(nproc)" && make install
    
# Optional: clean
RUN rm -rf /tmp/*
WORKDIR /workspaces
