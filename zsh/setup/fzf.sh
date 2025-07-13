#!/usr/bin/env zsh

set -e  # Exit on any command failure

require_once "$LIB_PATH/log.zsh"

if command -v fzf >/dev/null 2>&1; then
    log -f "fzf is already installed. Skipping installation."
else
    log -f "Installing fzf..."
    paru -S fzf
fi
