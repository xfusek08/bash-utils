#!/usr/bin/env zsh

set -e  # Exit on any command failure

require_once "$LIB_PATH/log.zsh"

if command -v bat >/dev/null 2>&1; then
    log -f "bat is already installed. Skipping installation."
else
    log -f "Installing bat..."
    paru -S bat
fi
