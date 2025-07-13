#!/usr/bin/env zsh

set -e  # Exit on any command failure

require_once "$LIB_PATH/log.zsh"

if command -v rustc >/dev/null 2>&1; then
    log -f "Rust SDK is already installed. Skipping installation."
else
    log -f "Installing Rust SDK."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi