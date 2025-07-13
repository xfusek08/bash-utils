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

# Dynamically source all setup scripts
SETUP_DIR="./setup"
if [[ -d "$SETUP_DIR" ]]; then
    # Find all .sh files in the setup directory and sort them
    for script in $(find "$SETUP_DIR" -name "*.sh" | sort); do
        script_name=$(basename "$script" .sh)
        echo "Running setup: $script_name"
        require_once "$script" || error_exit "$script_name setup"
    done
else
    error_exit "Setup directory not found: $SETUP_DIR"
fi

echo "Setup completed successfully!"
source ./setup/bat.sh || error_exit "Bat setup"

echo "Setup completed successfully!"
