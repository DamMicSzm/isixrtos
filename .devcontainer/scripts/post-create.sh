#!/usr/bin/env bash
#
# post-create.sh - Devcontainer post-creation setup
#
# This script is automatically executed inside the devcontainer after it is created.
# It performs an environment check and runs the initial build configuration if needed.
#
# Normally, you do not need to run this manually; it is run by the devcontainer setup.
#
# Usage (manual run, if needed):
#   ./devcontainer/scripts/post-create.sh
#
# No arguments are required or supported.
set -euo pipefail

install_clangd_if_missing() {
	local clangd_bin="${HOME}/.local/bin/clangd"
	if command -v clangd >/dev/null 2>&1 || [[ -x "${clangd_bin}" ]]; then
		echo "clangd already available."
		return 0
	fi

	echo "Installing clangd to ${clangd_bin}..."
	mkdir -p "${HOME}/.local/bin"
	local tmpdir
	tmpdir="$(mktemp -d)"
	trap 'rm -rf "${tmpdir}"' RETURN
	local version="19.1.2"
	curl -fsSL -o "${tmpdir}/clangd.zip" \
		"https://github.com/clangd/clangd/releases/download/${version}/clangd-linux-${version}.zip"
	if command -v unzip >/dev/null 2>&1; then
		unzip -qo "${tmpdir}/clangd.zip" -d "${tmpdir}"
	else
		python3 -c "import zipfile; z=zipfile.ZipFile('${tmpdir}/clangd.zip'); z.extractall('${tmpdir}')"
	fi
	cp -f "${tmpdir}/clangd_${version}/bin/clangd" "${clangd_bin}"
	chmod +x "${clangd_bin}"
	echo "Installed clangd ${version}."
}

echo "Checking required tools in devcontainer..."
meson --version
ninja --version
arm-none-eabi-gcc --version | sed -n '1p'
	qemu-system-arm --version | sed -n '1p'

install_clangd_if_missing

if [[ ! -d build ]]; then
	echo "No build directory found. Running initial configure for QEMU..."
	./configure build qemu
else
	echo "Build directory already exists. Skipping initial configure."
fi

# QEMU-only VS Code debug/tasks (devcontainer); source: .devcontainer/vscode/
if [[ -d .devcontainer/vscode ]]; then
	mkdir -p .vscode
	cp .devcontainer/vscode/launch.json .vscode/launch.json
	cp .devcontainer/vscode/tasks.json .vscode/tasks.json
	cp .devcontainer/vscode/settings.json .vscode/settings.json
	cp .devcontainer/vscode/extensions.json .vscode/extensions.json
	echo "Installed QEMU debug and editor config in .vscode/ (from .devcontainer/vscode/)"
fi

echo "Devcontainer setup check completed."
