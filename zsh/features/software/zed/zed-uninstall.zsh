function zed-uninstall() {
    # prepare directories
    # -------------------
    local main_directory="$HOME/.zed"
    local install_directory="$main_directory/zed"
    
    # Remove installation directory
    # ---------------------------
    if [ -d "$install_directory" ]; then
        echo "Removing Zed installation directory"
        rm -rf "$install_directory"
    fi
    
    # Remove symbolic link
    # -------------------
    if [ -L "$HOME/.local/bin/zed" ]; then
        echo "Removing Zed executable link"
        rm -f "$HOME/.local/bin/zed"
    fi
    
    # Remove desktop entry
    # -------------------
    if [ -f "$HOME/.local/share/applications/zed.desktop" ]; then
        echo "Removing Zed desktop entry"
        rm -f "$HOME/.local/share/applications/zed.desktop"
    fi
    
    # Remove cache directory
    # ---------------------
    if [ -d "$HOME/.cache/zed" ]; then
        echo "Removing Zed cache directory"
        rm -rf "$HOME/.cache/zed"
    fi
    
    # Clean up main directory if empty
    # ------------------------------
    if [ -d "$main_directory" ] && [ -z "$(ls -A "$main_directory")" ]; then
        echo "Removing empty Zed configuration directory"
        rm -rf "$main_directory"
    fi
    
    echo "Zed uninstallation completed"
}
