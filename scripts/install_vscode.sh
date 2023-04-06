#!/bin/bash

#
# Function: install_vscode
#
# Description:
#   This function downloads and installs the latest stable version of Visual Studio Code for Linux x64.
#   It uses `wget` to download the .deb package and `dpkg` to install it.
#
# Usage:
#   install_vscode [-h|--help]
#
# Options:
#   -h, --help    Display this help message and exit.
#
# Dependencies:
#   This function requires `wget` and `dpkg` to be installed.
#
# Examples:
#   install_vscode
#
# Notes:
#   - This function installs the latest stable version of Visual Studio Code for Linux x64.
#   - This function requires the following dependencies: wget, dpkg.
#   - This script has been tested on Ubuntu and should work on other Debian-based distributions as well.
#
# Author:
#     Petr Fusek: petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me document and code this script! 🤖
#

unalias install_vscode 2>/dev/null #remove potential alias
install_vscode() {
    # Parse options and arguments
    local help=false
    local opts
    opts=$(getopt -o h --long help -n 'install_vscode' -- "$@")
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
Usage: install_vscode [OPTIONS]

Downloads and installs the latest stable version of Visual Studio Code for Linux x64.

Options:
    -h, --help    Display this help message and exit.

Examples:
    install_vscode

Notes:
    - This function installs the latest stable version of Visual Studio Code for Linux x64.
    - This function requires the following dependencies: wget, dpkg.
    - This script has been tested on Ubuntu and should work on other Debian-based distributions as well.
EOF
        return 0
    fi

    # Download the latest stable version of Visual Studio Code
    wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O /tmp/code_latest_amd64.deb
    
    # Install Visual Studio Code using dpkg
    sudo dpkg -i /tmp/code_latest_amd64.deb
}
