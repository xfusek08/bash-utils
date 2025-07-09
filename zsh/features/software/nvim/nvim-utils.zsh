require_once "$LIB_PATH/log.zsh"
require_once '../../utils/ensure_directory.zsh'

function nvim-directories-exist() {
    [ -d "$HOME/.config/nvim" ] || [ -d "$HOME/.local/share/nvim" ] || [ -d "$HOME/.local/state/nvim" ] || [ -d "$HOME/.cache/nvim" ]
}


function ensure_nvim_backup_file() {
    ensure_directory "$ZSH_BACKUP_DIR"
    if [ $? -ne 0 ]; then
        log -e "Failed to access backup directory"
        return 1
    fi
    
    local backup_file="$ZSH_BACKUP_DIR/nvim-backup.zip"
    
    if [ ! -f "$backup_file" ]; then
        log -e "No backup file found at $backup_file"
        return 1
    fi
    
    echo "$backup_file"
    return 0
}

function remove_nvim_directories() {
    log -f "Removing neovim configuration directories"
    [ -d "$HOME/.config/nvim" ] && rm -rf "$HOME/.config/nvim" && log -f "Removed $HOME/.config/nvim"
    [ -d "$HOME/.local/share/nvim" ] && rm -rf "$HOME/.local/share/nvim" && log -f "Removed $HOME/.local/share/nvim"
    [ -d "$HOME/.local/state/nvim" ] && rm -rf "$HOME/.local/state/nvim" && log -f "Removed $HOME/.local/state/nvim"
    [ -d "$HOME/.cache/nvim" ] && rm -rf "$HOME/.cache/nvim" && log -f "Removed $HOME/.cache/nvim"
}
