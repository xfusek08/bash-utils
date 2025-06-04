require_once "$LIB_PATH/log.zsh"
require_once "./nvim-backup.zsh"
require_once "./nvim-utils.zsh"

function nvim-uninstall() {
    log -f "Starting neovim uninstallation process"
    
    # Backup current configuration before uninstalling
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
    
    # Remove neovim package
    log -f "Removing neovim package"
    sudo apt-get purge -y neovim
    if [ $? -eq 0 ]; then
        log -f "Neovim package removed successfully"
    else
        log -e "Failed to remove neovim package"
        return 1
    fi
    
    # Clean up any remaining dependencies
    sudo apt-get autoremove -y
    
    # Remove neovim configuration directories
    remove_nvim_directories
    
    log -f "Neovim uninstallation completed"
    
    return 0
}
