FROM ubuntu:18.04 AS gnu-toolchain-builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
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
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/riscv-toolchain

RUN git clone --recursive https://github.com/pulp-platform/pulp-riscv-gnu-toolchain.git .

RUN ./configure --prefix=/opt/riscv \
                --with-arch=rv32imc \
                --with-cmodel=medlow \
                --enable-multilib \
                 && make -j$(nproc)

RUN /opt/riscv/bin/riscv32-unknown-elf-gcc --version


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
        apt-get install -y --no-install-recommends \
    gcc-5 \
    g++-5 && \
        update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 50 --slave /usr/bin/g++ g++ /usr/bin/g++-5 && \
        rm -rf /var/lib/lists/* && \
        gcc --version

FROM ubuntu:18.04 AS sdk-installer

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	git \
	python3-pip \
	python-pip \
	gawk \
	texinfo \
	libgmp-dev \
	libmpfr-dev \
	libmpc-dev \
	swig3.0 \
	libjpeg-dev \
	lsb-core \
	doxygen \
	python-sphinx \
	sox \
	graphicsmagick-libmagick-dev-compat \
	libsdl2-dev \
	libswitch-perl \
	libftdi1-dev \
	cmake \
	scons \
	libsndfile1-dev \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=gnu-toolchain-builder /opt/riscv /opt/riscv

ENV PULP_RISCV_GCC_TOOLCHAIN=/opt/riscv
ENV PATH="$PULP_RISCV_GCC_TOOLCHAIN/bin:$PATH"
ENV PULP_SDK_HOME=/opt/pulp-sdk

RUN pip3 install artifactory twisted prettytable sqlalchemy pyelftools 'openpyxl==2.6.4' 'xlsxwriter==2.0.0' pyyaml numpy configparser pyvcd

RUN pip2 install configparser

WORKDIR /opt/pulp-sdk

RUN git clone --branch v1 https://github.com/pulp-platform/pulp-sdk.git .  


RUN bash -c "source configs/pulpissimo.sh && make -j\$(nproc) all"

RUN git clone https://github.com/pulp-platform/pulp-rt-examples.git /opt/pulp-sdk/pulp-rt-examples

                        
