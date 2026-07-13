# Devcontainer quick start (Phase 1)

This project now includes a QEMU-focused devcontainer for isolated development.

Base image: **Debian 13 (trixie)** slim.

## What this includes

- Meson (>= 1.2) + Ninja build tools (Meson from Debian packages)
- `arm-none-eabi` toolchain built from source (GCC 16.1, newlib, gdb)
- Patched QEMU (`v10.1.2`) for STM32 timer fixes required by ISIX tests
- Helper scripts for first setup and QEMU execution

The Phase 1 container is intentionally focused on **QEMU workflow only**. Hardware USB flashing/debugging (OpenOCD/ST-Link passthrough) is planned for a later phase.

`PATH` is configured automatically (`meson`, `arm-none-eabi-gcc`, `qemu-system-arm`).

## Before reopening in container

Install and configure these on the **host** (your PC), not inside the container.

### Container runtime (required)

You need a working container engine before **Reopen in Container**:

| Host OS | What to install |
|---------|-----------------|
| Linux | [Docker Engine](https://docs.docker.com/engine/install/) or [Podman](https://podman.io/docs/installation) |
| Windows | [Docker Desktop](https://www.docker.com/products/docker-desktop/) with **WSL2** backend |
| macOS | [Docker Desktop](https://www.docker.com/products/docker-desktop/) |

Check that it runs:

```bash
docker ps
# or, with Podman:
podman ps
```

On Linux with Podman, enable Docker-compatible socket if Cursor/VS Code expects `docker` (e.g. `podman-docker` package or `systemctl --user enable --now podman.socket`).

**First image build is slow** (often 30–60+ minutes): the image compiles the ARM toolchain from source and builds patched QEMU. Later opens are much faster unless you change `.devcontainer/Dockerfile`.

### Editor extension (required)

Install the **Dev Containers** extension in Cursor or VS Code:

- Extension ID: `ms-vscode-remote.remote-containers`
- In Cursor: Extensions → search **Dev Containers** → Install

Without it, **Reopen in Container** is not available.

### Recommended extensions (installed automatically in container)

These are defined in `.devcontainer/devcontainer.json` and are installed when the container is created:

| Extension | ID | Purpose |
|-----------|-----|---------|
| C/C++ | `ms-vscode.cpptools` | IntelliSense, debugging |
| C/C++ Extension Pack | `ms-vscode.cpptools-extension-pack` | C/C++ tooling bundle |
| Meson build | `mesonbuild.mesonbuild` | `meson.build` syntax and tasks |

You do not need to install them on the host; the devcontainer pulls them on first open.

### Other host requirements

- **Git** — clone the repository on the host.
- **Network** — first build downloads GCC/newlib sources, QEMU sources, and Debian packages.
- **Disk space** — allow several GB for image layers and build cache.
- **RAM** — toolchain and QEMU compile steps are heavy; 8 GB host RAM minimum, 16 GB recommended.

### Reopen / rebuild commands

| Action | When to use |
|--------|-------------|
| **Dev Containers: Reopen in Container** | Normal open after prerequisites are met |
| **Dev Containers: Rebuild Container** | After changing `.devcontainer/Dockerfile` or when the environment is broken |
| **Dev Containers: Rebuild Container Without Cache** | Clean rebuild from scratch |

After a Dockerfile change, always **rebuild** (not just reopen). If you had a stale `build/` directory from an old compiler, remove it and reconfigure:

```bash
rm -rf build
./configure build qemu
meson compile -C build
```

## Quick start

1. Open the repository in Cursor/VS Code.
2. Reopen folder in container.
3. Wait until the container image is built.
4. Run:

```bash
./configure build qemu
meson compile -C build
bash .devcontainer/scripts/qemu-run.sh
```

## Run with GDB wait

Use this if you want to attach `arm-none-eabi-gdb` on port `1234`:

```bash
qemu-system-arm -M olimex-stm32-h405 -semihosting \
  -kernel build/tests/libisix/isixtests.binary -nographic -S -s
```

## Notes for host operating systems

- Linux: fully supported for this QEMU-only phase.
- Windows (WSL2): supported when Docker is integrated with WSL2.
- macOS: supported for QEMU-only workflow.

## Keep host workflow unchanged

Devcontainer support is optional. Native host workflow remains valid:

```bash
./configure build qemu
meson compile -C build
```

## Cleanup

To fully remove the environment:

- delete the devcontainer instance
- remove generated docker image/layers if desired
- remove `build/` directory if you want a clean repo state
