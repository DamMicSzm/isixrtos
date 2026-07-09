# Devcontainer quick start (Phase 1)

This project now includes a QEMU-focused devcontainer for isolated development.

## What this includes

- Meson + Ninja build tools
- `arm-none-eabi` toolchain
- Patched QEMU (`v10.1.2`) for STM32 timer fixes required by ISIX tests
- Helper scripts for first setup and QEMU execution

The Phase 1 container is intentionally focused on **QEMU workflow only**. Hardware USB flashing/debugging (OpenOCD/ST-Link passthrough) is planned for a later phase.

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
