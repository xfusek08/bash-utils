
# Basic deb package installation
alias install_deb_package='sudo dpkg -i'

# URL-based deb package installation
function install_deb_package_url() {
    # ...existing code from install_deb_package_url.sh...
    local url="$1"
    
    # Download the .deb package
    wget "$url" -O /tmp/package.deb || {
        echo "ERROR: Failed to download the .deb package from $url" >&2
        return 1
    }
    
    # Install the package
    install_deb_package /tmp/package.deb || {
        echo "ERROR: Failed to install the package." >&2
        return 1
    }
    
    echo "Package installed successfully."
}
