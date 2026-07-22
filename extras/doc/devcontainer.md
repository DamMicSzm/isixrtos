# Devcontainer quick start (Phase 1)

This project now includes a QEMU-focused devcontainer for isolated development.

Base image: **Debian 13 (trixie)** slim (current stable).

## What this includes

- Meson (>= 1.2) + Ninja build tools
- `arm-none-eabi` toolchain built from source (GCC 16.1, newlib, gdb)
- Patched QEMU (`v10.1.2`) for STM32 timer fixes required by ISIX tests
- Helper scripts for first setup and QEMU execution

The Phase 1 container is intentionally focused on **QEMU workflow only**. Hardware USB flashing/debugging (OpenOCD/ST-Link passthrough) is planned for a later phase.

`PATH` is configured automatically (`meson`, `arm-none-eabi-gcc`, `qemu-system-arm`).

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

## Debug in VS Code / Cursor (QEMU)

On container create, `post-create.sh` copies QEMU-only debug configs from
`.devcontainer/vscode/` into `.vscode/` (not used outside the devcontainer).

### Required extensions (auto-installed in devcontainer)

| Extension | ID | Role |
|-----------|-----|------|
| **C/C++ Debug** | `kylinideteam.cppdebug` | `cppdbg` launch configs, breakpoints, **Disassembly View** |
| **Native Debug** | `webfreak.debug` | Alternative `gdb` launch configs, good for asm stepping |
| **clangd** | `llvm-vs-code-extensions.vscode-clangd` | Go to definition (not debug) |

`ms-vscode.cpptools` is not available in Cursor; use `kylinideteam.cppdebug` instead.

### Start debugging

1. **Run and Debug** (Ctrl+Shift+D)
2. Choose one of:
   - **QEMU: debug isixtests (start QEMU)** — builds, starts QEMU paused, attaches GDB (recommended)
   - **QEMU: attach isixtests** — attach when QEMU already runs (`qemu-gdb-server.sh`)
   - **QEMU: GDB start QEMU (Native Debug)** — same via Native Debug extension
3. GDB stops at reset; press **Continue** (F5) once to reach `main`
4. Set breakpoints in `tests/libisix/*.cpp` or `libfoundation/src/sys/tiny_printf.c`

GDB connects to QEMU on port **1234** (forwarded by the devcontainer).

### Disassembly view (asm + C)

During an active debug session:

1. **Command Palette** → `Debug: Open Disassembly View`
2. Or use **Step Into** (`F11`) — with `disassemble-next-line on`, GDB shows asm next to source
3. For libgcc helpers (`__aeabi_uldivmod` / `bpabi.S`), use **Step Instruction** in the Disassembly view

Configs also enable `debug.allowBreakpointsEverywhere` so you can break on asm addresses.

## C/C++ navigation (Go to Definition, Find References)

Cursor does not ship Microsoft's `ms-vscode.cpptools` extension. The devcontainer installs **clangd** instead.

1. Run `./configure build qemu` at least once so `build/compile_commands.json` exists.
2. **Trust the workspace** if prompted (clangd does not run in Restricted Mode).
3. Reload the window after container create: **Developer: Reload Window**.
4. Wait for clangd to finish indexing (status bar: "clangd: idle").
5. Right-click a symbol → **Go to Definition** / **Go to References**, or use F12 / Shift+F12.

If navigation is empty or wrong, rebuild compile commands:

```bash
meson compile -C build
```

Then run **Developer: Reload Window** so clangd picks up changes.

### Troubleshooting

| Symptom | Cause / fix |
|---------|-------------|
| `TargetArchitecture not detected, assuming x86_64` | Harmless host-side warning; configs set `targetArchitecture: arm` and `set architecture arm` in GDB |
| Stops at `crt0.c` then `exited with code 0` | Firmware finished the full test suite and called semihosting `SYS_EXIT`. Set breakpoints **before** the second Continue, or use the preset `break main` and stop again there |
| GDB cannot connect | QEMU must be started with `-S -gdb tcp::1234` (use `qemu-gdb-server.sh`) |
| Session ends when tests complete | Expected with `-semihosting`; restart QEMU and attach again |

Hardware/OpenOCD debug configs remain in `extras/scripts/vscode_tpl/` (Phase 2).

## Run with GDB wait (manual)

Use this if you want to attach `arm-none-eabi-gdb` on port `1234`:

```bash
.devcontainer/scripts/qemu-gdb-server.sh
```

Or equivalently:

```bash
qemu-system-arm -M olimex-stm32-h405 -semihosting \
  -kernel build/tests/libisix/isixtests.binary -nographic -S -gdb tcp::1234
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
