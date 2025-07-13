#!/usr/bin/env zsh

set -e  # Exit on any command failure

require_once "$LIB_PATH/log.zsh"

# Check if Docker is already installed and working
if command -v docker >/dev/null 2>&1; then
    log -f "Docker is already installed. Checking if service is running..."
    if sudo systemctl is-active docker >/dev/null 2>&1; then
        log -f "Docker is already installed and running. Skipping installation."
        log -i "Displaying Docker version information"
        docker --version
    else
        log -f "Docker is installed but not running. Starting Docker service..."
        log -i "Starting Docker service to enable container functionality"
        sudo systemctl start docker
        log -i "Enabling Docker to start automatically at boot time"
        sudo systemctl enable docker
        log -i "Displaying Docker version information"
        docker --version
    fi
else
    log -f "Installing Docker and Docker Compose."

    log -i "Updating system packages before Docker installation"
    sudo paru -Syu

    log -i "Installing Docker, Docker Compose, and Docker Buildx packages"
    sudo paru -S docker docker-compose docker-buildx

    # Create docker group if it doesn't exist
    log -i "Creating Docker group if it doesn't already exist"
    sudo groupadd docker 2>/dev/null || true

    log -i "Adding current user to the Docker group for non-root usage"
    sudo usermod -aG docker $USER

    log -i "Activating Docker group membership for current session"
    newgrp docker

    log -i "Starting Docker service to enable container functionality"
    sudo systemctl start docker

    log -i "Enabling Docker to start automatically at boot time"
    sudo systemctl enable docker

    log -i "Displaying Docker version information"
    docker --version
fi

log -i "Running hello-world container to verify Docker installation"
docker run hello-world
