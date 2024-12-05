#!/bin/bash

#
# Alias:
#     install_deb_package
#
# Description:
#     This alias provides a shorthand for installing .deb packages using dpkg.
#
# Usage:
#     install_deb_package <package.deb>
#
# Examples:
#     install_deb_package package.deb
#
# Author:
#     Petr Fusek: petr.fusek97@gmail.com
#

unalias install_deb_package 2>/dev/null  # Remove any existing alias
alias install_deb_package='sudo dpkg -i'
