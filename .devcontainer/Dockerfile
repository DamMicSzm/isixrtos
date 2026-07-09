FROM debian:bookworm-slim AS qemu-builder

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
	zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone -b "${QEMU_VERSION}" --recurse-submodules https://gitlab.com/qemu-project/qemu.git
WORKDIR /tmp/qemu
RUN curl -fsSL "${QEMU_PATCH_URL}" -o /tmp/qemu.patch && patch -p1 < /tmp/qemu.patch
RUN ./configure --disable-xen --disable-werror --target-list="arm-softmmu" --prefix=/opt/qemu
RUN make -j"$(nproc)" && make install

FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/qemu/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	gcc-arm-none-eabi \
	gdb-multiarch \
	git \
	meson \
	ninja-build \
	python3 \
	python3-pip \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=qemu-builder /opt/qemu /opt/qemu

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
	&& useradd --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" \
	&& apt-get clean

WORKDIR /workspaces/isixrtos
USER ${USERNAME}
