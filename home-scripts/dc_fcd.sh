#!/bin/bash

# Function to open a new terminal, run a command, and return the result
fzdirmod() {
    # Get the directory name from argument or default to the current directory
    local dir_name="${1:-$(pwd)}"

    # Named pipe for inter-process communication
    local pipe="/tmp/fzfpipe"
    if [[ -p "$pipe" ]]; then
        rm "$pipe"
    fi
    mkfifo "$pipe"

    # Open file descriptor 3 for reading/writing to the named pipe
    exec 3<>"$pipe"

    # Display the directory in the current terminal (for user information)
    echo "Opening directory: $dir_name" > /dev/tty

    # Build the command to run in the new terminal
    local command="
        source ~/.bash_aliases;   # Source user's aliases (if needed)
        exec 3<>'$pipe';          # Reopen the pipe in the new shell
        fcd \"$dir_name\" -p >&3; # Execute 'fcd' command, output to pipe
        exec 3>&-;                # Close the pipe after the command
    "

    # Open a new terminal and execute the command via bash
    gnome-terminal -- bash -c "$command"

    # Read the output of the 'fcd' command from the pipe
    local final_dir
    final_dir=$(head -n1 <&3)

    # If the selected directory is not empty, echo it
    if [[ -n "$final_dir" ]]; then
        echo "$final_dir"
    fi

    # Close file descriptor and remove the named pipe
    exec 3>&-
    rm "$pipe"
}

# Call the fzdirmod function and store the selected directory in 'selected_dir'
selected_dir=$(fzdirmod "$1")

# If a directory was selected, open it in Double Commander
if [[ -n "$selected_dir" ]]; then
    doublecmd --no-splash --client "$selected_dir"
fi
