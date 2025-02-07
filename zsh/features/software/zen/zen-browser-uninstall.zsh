function zen-browser-uninstall() {
    
    # prepare directories
    # -------------------
    local main_directory="$HOME/.zen"
    local install_directory="$main_directory/zen"
    
    # Remove installation directory
    # ---------------------------
    if [ -d "$install_directory" ]; then
        echo "Removing Zen installation directory"
        rm -rf "$install_directory"
    fi
    
    # Remove symbolic link
    # -------------------
    if [ -L "$HOME/.local/bin/zen" ]; then
        echo "Removing Zen executable link"
        rm -f "$HOME/.local/bin/zen"
    fi
    
    # Remove desktop entry
    # -------------------
    if [ -f "$HOME/.local/share/applications/zen.desktop" ]; then
        echo "Removing Zen desktop entry"
        rm -f "$HOME/.local/share/applications/zen.desktop"
    fi
    
    # Remove cache directory
    # ---------------------
    if [ -d "$HOME/.cache/zen" ]; then
        echo "Removing Zen cache directory"
        rm -rf "$HOME/.cache/zen"
    fi
    
    # Clean up main directory if empty
    # ------------------------------
    if [ -d "$main_directory" ] && [ -z "$(ls -A "$main_directory")" ]; then
        echo "Removing empty Zen configuration directory"
        rm -rf "$main_directory"
    fi
    
    echo "Zen uninstallation completed"
}
