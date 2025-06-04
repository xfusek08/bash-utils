require_once '../../utils/ensure_directory.zsh'
require_once '../../utils/get_github_release_asset_url.zsh'
require_once '../../utils/download_and_extract.zsh'
require_once "$LIB_PATH/log.zsh"
require_once "./nvim-backup.zsh"
require_once "./nvim-utils.zsh"
require_once "./nvim-uninstall.zsh"

function nvim-install() {
    local force_flag=""
    local original_pwd=$PWD
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--force)
                force_flag="true"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: nvim-install [-f|--force]"
                return 1
                ;;
        esac
    done
    
    log -f "Starting neovim installation process"
    
    # Force uninstall if flag is passed
    # --------------------------------
    if [[ "$force_flag" == "true" ]]; then
        log -f "Force flag detected, uninstalling existing neovim first"
        if ! nvim-uninstall; then
            log -e "Failed to uninstall existing neovim"
            log -e "Installation aborted"
            return 1
        fi
        log -f "Existing neovim uninstalled successfully"
        # Change to a safe directory after uninstall
        cd "$HOME" || cd /tmp
    fi
    
    # prepare directories
    # -------------------
    log -f "Preparing directories for neovim installation"
    local nvim_install_dir="$HOME/.nvim"
    ensure_directory "$nvim_install_dir"
    ensure_directory "$HOME/.local/bin"
    
    # Check if neovim directories exist and backup if they do
    # ------------------------------------------------------
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
    
    # Download latest neovim release info
    # ----------------------------------
    log -f "Checking for latest neovim release"
    local tarball_url=$(get_github_release_asset_url "neovim/neovim" "nvim-linux-x86_64.tar.gz")
    if [[ -z "$tarball_url" ]]; then
        log -e "Failed to find neovim tarball download URL"
        return 1
    fi
    
    log -f "Downloading neovim from: $tarball_url"
    
    # Clear existing installation
    # --------------------------
    log -f "Clearing existing neovim installation directory"
    rm -rf "$nvim_install_dir"
    ensure_directory "$nvim_install_dir"
    
    # Download and extract neovim
    # ---------------------------
    log -f "Downloading and extracting neovim to $nvim_install_dir"
    if ! download_and_extract "$tarball_url" "$nvim_install_dir"; then
        log -e "Failed to download and extract neovim tarball"
        return 1
    fi
    
    # Register neovim executable
    # -------------------------
    log -f "Creating neovim executable link"
    [[ -L "$HOME/.local/bin/nvim" ]] && rm -f "$HOME/.local/bin/nvim"
    ln -sf "$nvim_install_dir/bin/nvim" "$HOME/.local/bin/nvim"
    
    log -f "Neovim installed successfully"
    
    # Install dependencies
    # -------------------
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
    
    # Install/Update LazyVim starter configuration
    # -------------------------------------------
    log -f "Installing/updating LazyVim starter configuration"
    
    # Ensure we're in a safe directory for git operations
    cd "$HOME" || cd /tmp
    
    if [ -d "$HOME/.config/nvim" ]; then
        if [ -d "$HOME/.config/nvim/.git" ]; then
            log -f "LazyVim repository exists, pulling latest changes"
            cd "$HOME/.config/nvim"
            git pull
            if [ $? -ne 0 ]; then
                log -e "Failed to pull LazyVim updates"
                cd "$original_pwd" 2>/dev/null || cd "$HOME"
                return 1
            fi
        else
            log -f "LazyVim directory exists but is not a git repository, removing and cloning fresh"
            rm -rf "$HOME/.config/nvim"
            git clone https://github.com/LazyVim/starter ~/.config/nvim
            if [ $? -ne 0 ]; then
                log -e "Failed to clone LazyVim starter"
                return 1
            fi
        fi
    else
        log -f "LazyVim not found, cloning fresh repository"
        git clone https://github.com/LazyVim/starter ~/.config/nvim
        if [ $? -ne 0 ]; then
            log -e "Failed to clone LazyVim starter"
            return 1
        fi
    fi
    
    log -f "LazyVim starter configuration installed/updated successfully"
    
    # Finalize installation
    # --------------------
    log -f "Neovim installation completed"
    log -f "Make sure $HOME/.local/bin is in your PATH"
    
    # Return to original directory if it still exists
    cd "$original_pwd" 2>/dev/null || cd "$HOME"
    
    return 0
}
