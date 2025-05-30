FROM ubuntu:22.04 AS gnu-toolchain-builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        autoconf \
        automake \
        autotools-dev \
        curl \
        libmpc-dev \
        libmpfr-dev \
        libgmp-dev \
        gawk \
        build-essential \
        bison \
        flex \
        texinfo \
        gperf \
        libtool \
        patchutils \
        bc \
        zlib1g-dev \
        git \
        && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/riscv-toolchain

RUN git clone --recursive https://github.com/pulp-platform/pulp-riscv-gnu-toolchain.git .

# RUN ./autogen.sh

RUN ./configure --prefix=/opt/riscv \
                --with-arch=rv32imc \
                --with-cmodel=medlow \
                --enable-multilib \
                 && make -j$(nproc)

RUN /opt/riscv/bin/riscv32-unknown-elf-gcc --version



FROM ubuntu:22.04 AS sdk-installer

# ARG TARGET_TRIPLE=riscv32-unknown-elf-gcc

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        curl \
        libmpc-dev \
        python3 \
        python3-pip \
        libftdi1 \
        libusb-1.0-0-dev \
        git \
        cmake \
        build-essential \
        libftdi-dev \
        doxygen \
        libsdl2-dev \
        scons \
        gtkwave \
        libsndfile1-dev \
        rsync \
        autoconf \
	automake \
        texinfo \
        libtool \
        pkg-config \
        libsdl2-ttf-dev \
        && rm -rf /var/lib/apt/lists/*

COPY --from=gnu-toolchain-builder /opt/riscv /opt/riscv

ENV PULP_RISCV_GCC_TOOLCHAIN=/opt/riscv
ENV PATH="$PULP_RISCV_GCC_TOOLCHAIN/bin:$PATH"

RUN riscv32-unknown-elf-gcc --version


WORKDIR /opt/pulp-sdk

RUN git clone --recursive https://github.com/pulp-platform/pulp-sdk.git .

RUN pip3 install argcomplete pyelftools prettytable six

# RUN source configs/pulp-open.sh

RUN bash -c "source configs/pulp-open.sh && make -j\$(nproc) build"

# RUN make build

CMD ["/bin/bash"]
