require_once "$LIB_PATH/log.zsh"
require_once "./nvim-backup.zsh"
require_once "./nvim-utils.zsh"

function nvim-uninstall() {
    local original_pwd=$PWD
    
    log -f "Starting neovim uninstallation process"
    
    # prepare directories
    # -------------------
    local nvim_install_dir="$HOME/.nvim"
    
    # Move to a safe directory before operations
    cd "$HOME" || cd /tmp
    
    # Backup current configuration before uninstalling
    # ------------------------------------------------
    if nvim-directories-exist; then
        log -f "Backing up current neovim configuration before uninstall"
        if ! nvim-backup; then
            log -e "Failed to backup neovim configuration"
            log -e "Uninstallation aborted to prevent data loss"
            return 1
        else
            log -f "Configuration backed up successfully"
        fi
    fi
    
    # Remove neovim installation directory
    # -----------------------------------
    if [ -d "$nvim_install_dir" ]; then
        log -f "Removing neovim installation directory"
        rm -rf "$nvim_install_dir"
        log -f "Neovim installation directory removed successfully"
    fi
    
    # Remove symbolic link
    # -------------------
    if [ -L "$HOME/.local/bin/nvim" ]; then
        log -f "Removing neovim executable link"
        rm -f "$HOME/.local/bin/nvim"
    fi
    
    # Remove neovim configuration directories
    # --------------------------------------
    remove_nvim_directories
    
    log -f "Neovim uninstallation completed"
    
    # Return to original directory if it still exists
    cd "$original_pwd" 2>/dev/null || cd "$HOME"
    
    return 0
}
