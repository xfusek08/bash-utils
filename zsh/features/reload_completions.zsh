
require_once "zsh/zsh-reload.zsh"

function reload_completions() {
    # Check if ZSH_COMPLETIONS_DIRECTORY is set and exists
    if [[ -z "$ZSH_COMPLETIONS_DIRECTORY" || ! -d "$ZSH_COMPLETIONS_DIRECTORY" ]]; then
        echo "Error: ZSH_COMPLETIONS_DIRECTORY is not set or does not exist."
        return 1
    fi
    
    local target_dir="/usr/local/share/zsh/site-functions"
    
    echo "Reloading completion files from $ZSH_COMPLETIONS_DIRECTORY to $target_dir"
    
    # Process each file in the completions directory
    for file in "$ZSH_COMPLETIONS_DIRECTORY"/*; do
        if [[ -f "$file" ]]; then
            local filename=$(basename "$file")
            local target="$target_dir/$filename"
            
            # Remove existing symlink if it exists
            if [[ -L "$target" ]]; then
                echo "Removing existing symlink: $target"
                sudo rm "$target"
            elif [[ -e "$target" ]]; then
                echo "Warning: $target exists but is not a symlink. Skipping."
                continue
            fi
            
            # Create new symlink
            echo "Creating symlink for $filename"
            sudo ln -s "$file" "$target"
        fi
    done
    
    echo "Completion files reloaded."
    
    zsh-reload
}
