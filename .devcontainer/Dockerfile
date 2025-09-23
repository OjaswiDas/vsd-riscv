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
# 6) Clean up
# ---------------------------------------------------------------------
RUN rm -rf /tmp/*
WORKDIR /workspaces
