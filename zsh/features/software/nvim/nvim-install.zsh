require_once '../../utils/ensure_directory.zsh'
require_once "$LIB_PATH/log.zsh"
require_once "./nvim-backup.zsh"
require_once "./nvim-utils.zsh"

function nvim-install() {
    log -f "Starting neovim installation process"
    
    # Check if neovim directories exist and backup if they do
    if nvim-directories-exist; then
        log -f "Existing neovim configuration found, creating backup"
        if ! nvim-backup; then
            log -e "Failed to backup existing neovim configuration"
            log -e "Installation aborted to prevent data loss"
            return 1
        fi
        log -f "Backup completed successfully"
    else
        log -f "No existing neovim configuration found, proceeding with installation"
    fi
    
    # Install neovim via apt
    log -f "Installing neovim via apt"
    sudo apt-get update
    if [ $? -ne 0 ]; then
        log -e "Failed to update package list"
        return 1
    fi
    
    sudo apt-get install -y neovim
    if [ $? -ne 0 ]; then
        log -e "Failed to install neovim"
        return 1
    fi
    
    log -f "Neovim installed successfully"
    
    # Install ripgrep if not already installed
    if ! command -v rg &> /dev/null; then
        log -f "Installing ripgrep"
        cargo install ripgrep
        if [ $? -ne 0 ]; then
            log -e "Failed to install ripgrep"
            return 1
        fi
        log -f "Ripgrep installed successfully"
    else
        log -f "Ripgrep already installed"
    fi
    
    # Install fd-find if not already installed
    if ! command -v fd &> /dev/null; then
        log -f "Installing fd-find"
        cargo install fd-find
        if [ $? -ne 0 ]; then
            log -e "Failed to install fd-find"
            return 1
        fi
        log -f "fd-find installed successfully"
    else
        log -f "fd-find already installed"
    fi
    
    # Install LazyVim starter configuration
    log -f "Installing LazyVim starter configuration"
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    if [ $? -ne 0 ]; then
        log -e "Failed to clone LazyVim starter"
        return 1
    fi
    
    rm -rf ~/.config/nvim/.git
    log -f "LazyVim starter configuration installed successfully"
    
    log -f "Neovim installation completed"
    
    return 0
}
