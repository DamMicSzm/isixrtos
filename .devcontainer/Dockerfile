FROM debian:trixie-slim AS toolchain-builder

ENV DEBIAN_FRONTEND=noninteractive
ARG PREFIX=/opt/arm-none-eabi-gcc

RUN apt-get update && apt-get install -y --no-install-recommends \
	bison \
	build-essential \
	ca-certificates \
	curl \
	flex \
	gawk \
	libexpat-dev \
	libgmp-dev \
	libisl-dev \
	libmpc-dev \
	libmpfr-dev \
	libreadline-dev \
	texinfo \
	xz-utils \
	zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/*

COPY extras/toolchain/versions.env /tmp/toolchain/versions.env
COPY extras/toolchain/linux /tmp/toolchain/linux
WORKDIR /tmp/toolchain/linux
ENV PREFIX="${PREFIX}"
RUN ./build-from-source.sh

FROM debian:trixie-slim AS qemu-builder

ARG QEMU_VERSION=v10.1.2
ARG QEMU_PATCH_URL=http://bryndza.boff.pl/downloads/prv/qemu-${QEMU_VERSION}-STM32-fix-raise-interrupt-time.patch

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	ca-certificates \
	curl \
	git \
	libfdt-dev \
	libglib2.0-dev \
	libpixman-1-dev \
	ninja-build \
	pkg-config \
	python3 \
	python3-pip \
	python3-venv \
	zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone -b "${QEMU_VERSION}" --recurse-submodules https://gitlab.com/qemu-project/qemu.git
WORKDIR /tmp/qemu
RUN curl -fsSL "${QEMU_PATCH_URL}" -o /tmp/qemu.patch && patch -p1 < /tmp/qemu.patch
RUN ./configure --disable-xen --disable-werror --target-list="arm-softmmu" --prefix=/opt/qemu
RUN make -j"$(nproc)" && make install

FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/python-tools/bin:/opt/arm-none-eabi-gcc/bin:/opt/qemu/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	clangd \
	curl \
	git \
	libfdt1 \
	libglib2.0-0t64 \
	libisl23 \
	libmpc3 \
	libmpfr6 \
	libpixman-1-0 \
	ninja-build \
	python3 \
	python3-pip \
	python3-venv \
	unzip \
	&& python3 -m venv /opt/python-tools \
	&& /opt/python-tools/bin/pip install --no-cache-dir 'meson>=1.2' \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=toolchain-builder /opt/arm-none-eabi-gcc /opt/arm-none-eabi-gcc
COPY --from=qemu-builder /opt/qemu /opt/qemu

RUN ldd /opt/qemu/bin/qemu-system-arm | (! grep -q 'not found') \
	&& ldd /opt/arm-none-eabi-gcc/libexec/gcc/arm-none-eabi/*/cc1 | (! grep -q 'not found')

RUN printf '%s\n' \
	'export PATH="/opt/python-tools/bin:/opt/arm-none-eabi-gcc/bin:/opt/qemu/bin:${PATH}"' \
	> /etc/profile.d/isixrtos-toolchain.sh \
	&& chmod 644 /etc/profile.d/isixrtos-toolchain.sh

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
	&& useradd --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" \
	&& apt-get clean

WORKDIR /workspaces/isixrtos
USER ${USERNAME}
