require_once "$LIB_PATH/log.zsh"
require_once  "../../utils/ensure_zsh_backup_dir.zsh"

function zen-browser-backup() {
    ensure_zsh_backup_dir
    if [ $? -ne 0 ]; then
        log -e "Failed to create backup directory"
        return 1
    fi
    
    local backup_file_name="$ZSH_BACKUP_DIR/zen-browser-backup.zip"
    local main_directory="$HOME/.zen"
    
    # Save original directory
    local original_dir
    original_dir="$(pwd)"
    
    # Remove previous backup if it exists
    [ -f "$backup_file_name" ] && rm "$backup_file_name"
    
    # Change working directory to main_directory for relative paths
    cd "$main_directory" || { log -e "Failed to change directory to $main_directory"; return 1; }
    
    log -f "Backing up zen browser from $(pwd) to $backup_file_name"
    
    # Zip all files in main_directory excluding "zen" directory and tar.gz/zip files using relative paths:
    zip -qr "$backup_file_name" . -x "zen/*" -x "*.tar.gz" -x "*.zip"
    
    if [ $? -ne 0 ]; then
        # Restore original directory before exit
        cd "$original_dir"
        log -e "Failed to backup zen browser"
        return 1
    fi
    
    log -f "Backup completed"
    
    # Restore original directory
    cd "$original_dir"
    
    return 0
}
