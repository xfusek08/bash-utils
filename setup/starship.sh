#!/usr/bin/env zsh

set -e  # Exit on any command failure

require_once "$LIB_PATH/log.zsh"

if command -v starship >/dev/null 2>&1; then
    log -f "starship is already installed. Skipping installation."
else
    log -f "Installing starship..."
    cargo install starship
fi
