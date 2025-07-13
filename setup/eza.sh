#!/usr/bin/env zsh

set -e  # Exit on any command failure

require_once "$LIB_PATH/log.zsh"

if command -v eza >/dev/null 2>&1; then
    log -f "eza is already installed. Skipping installation."
else
    log -f "Installing eza..."
    cargo install eza
fi
