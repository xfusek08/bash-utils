#!/usr/bin/env zsh

set -e  # Exit on any command failure

require_once "$LIB_PATH/log.zsh"

ZSH_PATH=$(which zsh)

if [[ "$SHELL" == "$ZSH_PATH" ]]; then
    log -f "ZSH is already the default shell. Skipping..."
else
    log -f "Setting up ZSH as default shell."
    chsh -s "$ZSH_PATH"
fi
