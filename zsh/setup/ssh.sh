#!/bin/bash

# This script sets up the GNOME crypto SSH agent (gcr-ssh-agent) on CachyOS
# to cache your SSH keys securely and avoid repeated passphrase prompts.

set -e

SSH_KEY=""
if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
    SSH_KEY="$HOME/.ssh/id_ed25519"
elif [[ -f "$HOME/.ssh/id_rsa" ]]; then
    SSH_KEY="$HOME/.ssh/id_rsa"
fi
if [[ -z "$SSH_KEY" ]]; then
    echo "No SSH key found in ~/.ssh/. Generating a new ed25519 key."
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$HOME/.ssh/id_ed25519"
    SSH_KEY="$HOME/.ssh/id_ed25519"
    echo "Please add the following public key to your GitHub account:"
    cat "${SSH_KEY}.pub"
fi


echo "Installing necessary packages..."
paru -S --needed gcr

echo "Enabling and starting gcr-ssh-agent systemd user socket..."
systemctl --user enable --now gcr-ssh-agent.socket

# Export SSH_AUTH_SOCK for this shell session
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
echo "Exported SSH_AUTH_SOCK=$SSH_AUTH_SOCK"

# Add your default SSH key (id_rsa or id_ed25519)
if [ -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-add "$HOME/.ssh/id_ed25519"
elif [ -f "$HOME/.ssh/id_rsa" ]; then
    ssh-add "$HOME/.ssh/id_rsa"
else
    echo "No default SSH key found at ~/.ssh/id_ed25519 or ~/.ssh/id_rsa"
    echo "Please generate one with ssh-keygen or specify your key manually."
fi

echo
echo "IMPORTANT:"
echo "Add the following line to your shell config (~/.bashrc, ~/.zshrc, or your Wayland session startup script) to set SSH_AUTH_SOCK automatically on login:"
echo
echo "    export SSH_AUTH_SOCK=\$XDG_RUNTIME_DIR/gcr/ssh"
echo
echo "This ensures all your shells and programs use the SSH agent automatically."
echo
echo "You will be prompted for your SSH key passphrase once after reboot or login."
echo "After that, the agent caches your keys for the session."
