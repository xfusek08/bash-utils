#!/bin/bash

# Function to run fzf in a new terminal and return the selected directory
fzdirmod() {
    # Get the directory from the argument or use the current working directory
    local dir_name="${1:-$(pwd)}"

    # Create a named pipe for inter-process communication
    local pipe="/tmp/fzfpipe"
    if [[ -p "$pipe" ]]; then
        rm "$pipe"
    fi
    mkfifo "$pipe"

    # Open file descriptor 3 for reading and writing to the named pipe
    exec 3<>"$pipe"

    # Show the current directory
    echo "Opening directory: $dir_name" > /dev/tty

    # Build the command to run inside a new terminal
    local command="
        source ~/.bash_aliases;   # Source aliases (optional, based on user setup)
        exec 3<>'$pipe';          # Reopen the pipe in the new shell
        fcd \"$dir_name\" -p >&3; # Run 'fcd' and write the result to the pipe
        exec 3>&-;                # Close the pipe after the command
    "

    # Open the new terminal window to execute the command
    gnome-terminal --geometry=1200x800 -- bash -c "$command"

    # Read the result from the pipe (the selected directory)
    local final_dir
    final_dir=$(head -n1 <&3)

    # If the directory is not empty, echo it
    if [[ -n "$final_dir" ]]; then
        echo "$final_dir"
    fi

    # Close the pipe and remove it
    exec 3>&-
    rm "$pipe"
}

# Call the function and store the result in 'selected_dir'
selected_dir=$(fzdirmod "$1")

# If a directory was selected, open it in Double Commander
if [[ -n "$selected_dir" ]]; then
    doublecmd --no-splash --client "$selected_dir"
fi
