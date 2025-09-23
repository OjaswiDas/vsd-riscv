FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Core build deps for Spike, pk, iverilog, etc.
RUN apt-get update && apt-get install -y \
    git vim curl wget ca-certificates \
    build-essential gcc g++ make pkg-config \
    autoconf automake autotools-dev libtool \
    bison flex texinfo gperf patchutils \
    gawk libmpc-dev libmpfr-dev libgmp-dev \
    zlib1g-dev libexpat1-dev \
    device-tree-compiler libfdt-dev \
    python3 \
 && rm -rf /var/lib/apt/lists/*

# RISC-V GCC (SiFive prebuilt, matches your script)
WORKDIR /opt
RUN wget -q https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz \
 && tar -xzf riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz \
 && mv riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14 /opt/riscv \
 && rm -f *.tar.gz
ENV PATH="/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin:${PATH}"

# Spike
WORKDIR /tmp
RUN git clone https://github.com/riscv/riscv-isa-sim.git && \
    cd riscv-isa-sim && \
    git submodule update --init --recursive && \
    mkdir build && cd build && \
    ../configure --prefix=/opt/riscv && \
    make -j"$(nproc)" && make install

# Proxy kernel (pk)
WORKDIR /tmp
RUN git clone https://github.com/riscv/riscv-pk.git && \
    cd riscv-pk && mkdir build && cd build && \
    ../configure --prefix=/opt/riscv --host=riscv64-unknown-elf && \
    make -j"$(nproc)" && make install

# Icarus Verilog
WORKDIR /tmp
RUN git clone https://github.com/steveicarus/iverilog.git && \
    cd iverilog && git checkout --track -b v10-branch origin/v10-branch && \
    chmod +x autoconf.sh && ./autoconf.sh && ./configure && \
    make -j"$(nproc)" && make install
