#!/usr/bin/env zsh

set -e  # Exit on any command failure

require_once "$LIB_PATH/log.zsh"
require_once "setup/rust-sdk.sh"  # Add dependency on Rust SDK

if command -v starship >/dev/null 2>&1; then
    log -f "starship is already installed. Skipping installation."
else
    log -f "Installing starship..."
    cargo install starship
fi
