function youtube-music-uninstall() {
    local force_flag=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--force)
                force_flag="true"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: youtube-music-uninstall [-f|--force]"
                return 1
                ;;
        esac
    done
    
    # prepare directories
    # -------------------
    local main_directory="$HOME/.youtube-music"
    local install_directory="$main_directory/app"
    local source_directory="$main_directory/source"
    
    # Remove installation directory
    # ----------------------------
    if [ -d "$install_directory" ]; then
        echo "Removing YouTube Music installation directory"
        rm -rf "$install_directory"
    fi
    
    # Remove source directory
    # ----------------------
    if [ -d "$source_directory" ]; then
        echo "Removing YouTube Music source directory"
        rm -rf "$source_directory"
    fi
    
    # Remove symbolic link
    # -------------------
    if [ -L "$HOME/.local/bin/youtube-music" ]; then
        echo "Removing YouTube Music executable link"
        rm -f "$HOME/.local/bin/youtube-music"
    fi
    
    # Remove desktop entry
    # -------------------
    if [ -f "$HOME/.local/share/applications/youtube-music.desktop" ]; then
        echo "Removing YouTube Music desktop entry"
        rm -f "$HOME/.local/share/applications/youtube-music.desktop"
    fi
    
    # Remove cache directory (only with force flag)
    # --------------------------------------------
    if [[ "$force_flag" == "true" ]] && [ -d "$HOME/.cache/youtube-music" ]; then
        echo "Removing YouTube Music cache directory"
        rm -rf "$HOME/.cache/youtube-music"
    fi
    
    # Remove config directory (only with force flag)
    # ---------------------------------------------
    if [[ "$force_flag" == "true" ]] && [ -d "$HOME/.config/YouTube Music" ]; then
        echo "Removing YouTube Music config directory"
        rm -rf "$HOME/.config/YouTube Music"
    fi
    
    # Clean up main directory if empty
    # ------------------------------
    if [ -d "$main_directory" ] && [ -z "$(ls -A "$main_directory")" ]; then
        echo "Removing empty YouTube Music configuration directory"
        rm -rf "$main_directory"
    fi
    
    echo "YouTube Music uninstallation completed"
}
