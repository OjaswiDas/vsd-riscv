FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
  git vim autoconf automake autotools-dev curl \
  libmpc-dev libmpfr-dev libgmp-dev gawk build-essential \
  bison flex texinfo gperf libtool patchutils bc zlib1g-dev \
  libexpat1-dev device-tree-compiler gtkwave wget ca-certificates \
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
    cd riscv-isa-sim && mkdir build && cd build && \
    ../configure --prefix=/opt/riscv && make -j"$(nproc)" && make install

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
