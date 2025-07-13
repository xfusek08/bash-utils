#!/usr/bin/env zsh

set -e  # Exit on any command failure

require_once "$LIB_PATH/log.zsh"

# Check if Docker is already installed and working
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    log -f "Docker is already installed and working. Skipping installation."
    docker --version
    return 0  # Use return instead of exit to continue setup
fi

log -f "Installing Docker and Docker Compose."

sudo paru -Syu

sudo paru -S docker docker-compose docker-buildx

sudo groupadd docker    # Create docker group if it doesn't exist

sudo usermod -aG docker $USER

newgrp docker

sudo systemctl start docker

sudo systemctl enable docker

docker --version

sudo service docker status

docker run hello-world
