#!/bin/bash

# Script:
#     install_vscode
#
# Description:
#     This script installs the latest stable version of Visual Studio Code for Linux x64 by using the install_deb_package function.
#
# Usage:
#     install_vscode [-h|--help]
#
# Options:
#     -h, --help    Display this help message and exit.
#
# Examples:
#     install_vscode    # Installs the latest stable version of Visual Studio Code.
#
# Author:
#     Petr Fusek
#     petr.fusek97@gmail.com
#
# Thanks to:
#     - Chat GPT for helping me code and document this script! 🤖
#

# Load the install_deb_package function (ensure the script path is correct)
. install_deb_package.sh

install_vscode() {
    # URL for the latest stable VS Code .deb package
    local vscode_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    
    # Use the generic function to install VS Code
    install_deb_package "$vscode_url"
}

# If the script is run directly (not sourced), "${BASH_SOURCE[0]}" equals "${0}".
# This ensures that the `install_vscode` function is only called when the script is executed directly.
# If sourced, the function is loaded but not automatically executed.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_vscode "$@"
fi
