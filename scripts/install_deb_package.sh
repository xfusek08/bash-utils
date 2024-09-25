#!/bin/bash

# Script:
#     install_deb_package
#
# Description:
#     This script downloads a .deb package from a given URL and installs it using `dpkg`.
#
# Usage:
#     install_deb_package <url> [-h|--help]
#
# Options:
#     -h, --help    Display this help message and exit.
#
# Dependencies:
#     Requires `wget` and `dpkg` to be installed.
#
# Examples:
#     install_deb_package https://example.com/package.deb
#
# Notes:
#     - This script installs any .deb package from the provided URL.
#     - The script has been tested on Ubuntu and should work on other Debian-based distributions as well.
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#

unalias install_deb_package 2>/dev/null # Remove potential alias

install_deb_package() {
    # Parse options and arguments
    local help=false
    local opts
    opts=$(getopt -o h --long help -n 'install_deb_package' -- "$@")
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to parse options." >&2
        return 1
    fi
    eval set -- "$opts"
    
    while true; do
        case "$1" in
            -h|--help)
                help=true
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "ERROR: Invalid option $1" >&2
                return 1
                ;;
        esac
    done

    # Show help message if -h option is specified
    if [ "$help" == "true" ]; then
        cat <<EOF
Usage: install_deb_package <url> [OPTIONS]

Downloads and installs a .deb package from the specified URL.

Options:
    -h, --help    Display this help message and exit.

Examples:
    install_deb_package https://example.com/package.deb

Notes:
    - Requires wget and dpkg to be installed.
    - Ensure you have sudo privileges to install packages.
EOF
        return 0
    fi

    # Check if a URL is provided
    if [ -z "$1" ]; then
        echo "ERROR: No URL provided." >&2
        return 1
    fi

    local url="$1"
    
    # Download the .deb package from the specified URL
    wget "$url" -O /tmp/package.deb
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to download the .deb package from $url" >&2
        return 1
    fi
    
    # Install the package using dpkg
    sudo dpkg -i /tmp/package.deb
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install the package." >&2
        return 1
    fi
    
    echo "Package installed successfully."
}

# If the script is run directly (not sourced), "${BASH_SOURCE[0]}" equals "${0}".
# This ensures that the `install_vscode` function is only called when the script is executed directly.
# If sourced, the function is loaded but not automatically executed.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_deb_package "$@"
fi
