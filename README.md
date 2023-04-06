# Bash Utils

This repository contains a collection of useful aliases and functions for the Bash shell.


1. `ask`: This function asks a yes/no question and returns 0 if the answer is `"yes"` and 1 if the answer is `"no"`. It can also take an optional argument to set the default answer.

1. `bat`: This alias is set to the command `batcat`, which is a syntax-highlighting cat clone.

1. `fcd`:  This command is a simple way to change the current directory to a directory selected interactively using `fzf`.

1. `findNoBin`: This alias finds all files in the current directory that are not binary files (using grep) and prints their paths.

1. `fzcode`: This script searches for source code files in a specified directory using `ripgrep` (rg).
It then presents the search results to the user in a fuzzy-search interface (fzf).
Once the user selects a line from the search results,
the script opens the corresponding file in the Visual Studio Code editor.

1. `histd`: This command removes any potential alias for the histd function to prevent conflicts with previously defined aliases.
histd() { ... }
This function allows the user to delete specific commands from their bash history.
1. `fzh`: This command removes any potential alias for the fzh function to prevent conflicts with previously defined aliases.
fzh() { ... }
This function provides a fuzzy search interface for the user to select a command from their bash history, and then either execute or delete it.
1. `fzp`: This command removes any potential alias for the fzp function to prevent conflicts with previously defined aliases.
alias fzp="findNoBin | fzf --preview \"batcat {} --color=always\""
This command creates an alias for the fzp function, which allows the user to fuzzy search for files in the current directory and its subdirectories, and preview them with syntax highlighting using batcat.
1. `install_vscode`: This command removes any potential alias for the install_vscode function to prevent conflicts with previously defined aliases.
install_vscode() { ... }
This function downloads and installs the latest stable version of Visual Studio Code for Linux x64.
alias ls='exa --icons --color=auto --group-directories-first'
This command creates an alias for the ls command, which lists the contents of the current directory with icons, colorized output, and directories listed first. The exa command is used instead of ls.