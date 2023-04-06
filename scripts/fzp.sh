#!/bin/bash

#
# Alias:
#     fzp
#
# Description:
#     This alias uses and registers the `findNoBin` alias and the `fzf` command to search for and preview files in the current
#     directory, excluding binary files and hidden directories. The selected file is then opened using `bat`
#     for syntax highlighting and git integration.
#
# Usage:
#     fzp
#
# Examples:
#     fzp
#
# Notes:
#     This alias requires the following dependencies:
#     - `find`
#     - `grep`
#     - `fzf`
#     - `bat`
#
# Author:
#     Petr Fusek: petr.fusek97@gmail.com
#
# Thanks to:
#     - The developers of `fzf` and `bat` for creating great tools.
#         - https://github.com/junegunn/fzf
#         - https://github.com/sharkdp/bat
#     - Chat GPT for helping me document this script! 🤖
#

. findNoBin.sh

unalias fzp 2>/dev/null #remove potential alias
alias fzp="findNoBin | fzf --preview \"batcat {} --color=always\""
