require_once "$LIB_PATH/log.zsh"
require_once  "../../utils/ensure_directory.zsh"

function zed-backup() {
    ensure_directory "$ZSH_BACKUP_DIR"
    
    if [ $? -ne 0 ]; then
        log -e "Failed to create backup directory"
        return 1
    fi
    
    local backup_file_name="$ZSH_BACKUP_DIR/zed-backup.zip"
    local main_directory="$HOME/.zed"
    
    # Save original directory
    local original_dir
    original_dir="$(pwd)"
    
    # Remove previous backup if it exists
    [ -f "$backup_file_name" ] && rm "$backup_file_name"
    
    # Change working directory to main_directory for relative paths
    cd "$main_directory" || { log -e "Failed to change directory to $main_directory"; return 1; }
    
    log -f "Backing up zed editor from $(pwd) to $backup_file_name"
    
    # Zip all files in main_directory excluding "zed" directory and existing archives:
    zip -qr "$backup_file_name" . -x "zed/*" -x "*.tar.gz" -x "*.zip"
    
    if [ $? -ne 0 ]; then
        cd "$original_dir"
        log -e "Failed to backup zed editor"
        return 1
    fi
    
    log -f "Backup completed"
    cd "$original_dir"
    return 0
}
