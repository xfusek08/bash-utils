function lazygit-uninstall() {
    # prepare directories
    # -------------------
    local main_directory="$HOME/.lazygit"
    local install_directory="$main_directory/lazygit"
    
    # Remove installation directory
    # ----------------------------
    if [ -d "$install_directory" ]; then
        echo "Removing lazygit installation directory"
        rm -rf "$install_directory"
    fi
    
    # Remove symbolic link
    # -------------------
    if [ -L "$HOME/.local/bin/lazygit" ]; then
        echo "Removing lazygit executable link"
        rm -f "$HOME/.local/bin/lazygit"
    fi
    
    # Remove lazygit configuration directories
    # ---------------------------------------
    if [ -d "$HOME/.config/lazygit" ]; then
        echo "Removing lazygit configuration directory"
        rm -rf "$HOME/.config/lazygit"
    fi
    
    if [ -d "$HOME/.local/state/lazygit" ]; then
        echo "Removing lazygit state directory"
        rm -rf "$HOME/.local/state/lazygit"
    fi
    
    # Clean up main directory if empty
    # -------------------------------
    if [ -d "$main_directory" ] && [ -z "$(ls -A "$main_directory")" ]; then
        echo "Removing empty lazygit configuration directory"
        rm -rf "$main_directory"
    fi
    
    echo "Lazygit uninstallation completed"
}
