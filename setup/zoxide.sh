#!/usr/bin/env zsh

set -e  # Exit on any command failure

require_once "$LIB_PATH/log.zsh"

if command -v zoxide >/dev/null 2>&1; then
    log -f "zoxide is already installed. Skipping installation."
else
    log -f "Installing zoxide..."
    cargo install zoxide
fi
