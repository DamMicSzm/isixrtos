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

echo "Checking required tools in devcontainer..."
meson --version
ninja --version
arm-none-eabi-gcc --version | sed -n '1p'
qemu-system-arm --version | sed -n '1p'

if [[ ! -d build ]]; then
	echo "No build directory found. Running initial configure for QEMU..."
	./configure build qemu
else
	echo "Build directory already exists. Skipping initial configure."
fi

echo "Devcontainer setup check completed."
