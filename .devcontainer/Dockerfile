FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# -------------------------------
# 0) Base build dependencies
# -------------------------------
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

# Allow overriding parallelism at build-time:
#   docker build --build-arg MAKE_JOBS=8 ...
ARG MAKE_JOBS
ENV MAKE_JOBS=${MAKE_JOBS:-$(nproc)}

# -------------------------------
# 1) Sanity: host GCC must work (clean PATH)
# -------------------------------
RUN echo 'int main(){return 0;}' > /tmp/cc.c && \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    gcc /tmp/cc.c -o /tmp/cc && /tmp/cc

# -------------------------------
# 2) Spike (host build; keep PATH clean)
# -------------------------------
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/riscv/riscv-isa-sim.git && \
    cd riscv-isa-sim && git submodule update --init --recursive && \
    mkdir build && cd build && \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    ../configure --prefix=/opt/riscv \
      || { echo '--- spike config.log ---'; cat config.log || true; exit 1; } && \
    make -j"${MAKE_JOBS}" && make install

# -------------------------------
# 3) riscv-gnu-toolchain (newlib)
#    Builds the cross toolchain into /opt/riscv
# -------------------------------
WORKDIR /tmp
RUN git clone --depth 1 --recursive \
      https://github.com/riscv-collab/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain && \
    # If submodules are shallow, ensure they’re initialized:
    git submodule update --init --recursive --depth 1 && \
    mkdir build && cd build && \
    ../configure --prefix=/opt/riscv \
                 --with-arch=rv64imac \
                 --with-abi=lp64 && \
    make -j"${MAKE_JOBS}" newlib

# Expose cross toolchain AFTER Spike is built (avoid PATH collisions)
ENV PATH="/opt/riscv/bin:${PATH}"

# Quick sanity on the cross toolchain (fail fast if not present)
RUN which riscv64-unknown-elf-gcc && riscv64-unknown-elf-gcc --version

# -------------------------------
# 4) riscv-pk (proxy kernel) with cross toolchain
# -------------------------------
WORKDIR /tmp
RUN set -eux; \
    git clone --depth 1 https://github.com/riscv/riscv-pk.git; \
    cd riscv-pk; mkdir -p build; cd build; \
    CC=riscv64-unknown-elf-gcc \
    CXX=riscv64-unknown-elf-g++ \
    AR=riscv64-unknown-elf-ar \
    RANLIB=riscv64-unknown-elf-ranlib \
    ../configure --prefix=/opt/riscv --host=riscv64-unknown-elf \
      || { echo '--- pk config.log ---'; cat config.log || true; exit 1; }; \
    make -j"${MAKE_JOBS}" V=1; \
    make install

# -------------------------------
# 5) Cleanup
# -------------------------------
RUN rm -rf /tmp/*

# Codespaces default workdir
WORKDIR /workspaces
