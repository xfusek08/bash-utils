#!/usr/bin/env zsh

set -e  # Exit on any command failure

# Error handler
error_exit() {
    echo "Error: Setup failed at step: $1"
    exit 1
}

trap 'error_exit "Unknown step"' ERR

ZSH_DEBUG=true
ZSH_SCRIPTING_LOG_LEVEL=INFO

ZSH_BACKUP_DIR="${ZSH_BACKUP_DIR:-$HOME/Backup}"
[ ! -d "$ZSH_BACKUP_DIR" ] && mkdir -p "$ZSH_BACKUP_DIR"

ZSH_SCRIPTING_DIRECTORY=${ZSH_SCRIPTING_DIRECTORY:-"$HOME/Repo/bash-utils/zsh"}
ZSH_SCRIPTING_BOOTSTRAP="$ZSH_SCRIPTING_DIRECTORY/core/bootstrap.zsh"

echo "$ZSH_SCRIPTING_DIRECTORY"

# if loader does not exist, create it
if [ -f "$ZSH_SCRIPTING_BOOTSTRAP" ]; then
    source "$ZSH_SCRIPTING_BOOTSTRAP"
else
    echo "Failed to load ZSH scripting environment."
    exit 1
fi

source ./setup/zsh-default.sh || error_exit "ZSH setup"

source ./setup/docker.sh || error_exit "Docker setup"

source ./setup/rust-sdk.sh || error_exit "Rust SDK setup"

source ./setup/starship.sh || error_exit "Starship setup"

source ./setup/zoxide.sh || error_exit "Zoxide setup"

source ./setup/eza.sh || error_exit "Eza setup"

source ./setup/fzf.sh || error_exit "FZF setup"

source ./setup/bat.sh || error_exit "Bat setup"

echo "Setup completed successfully!"
