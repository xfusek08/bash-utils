require_once "$LIB_PATH/log.zsh"
require_once  "../../utils/ensure_zsh_backup_dir.zsh"

function zen-browser-backup() {
    # Parse arguments for restore flag
    # -------------------------------
    log -f "Parsing arguments"
    local restore=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r|--restore)
                restore=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Setup variables
    # --------------
    log -f "Setting up variables"
    local backup_file_name="$ZSH_BACKUP_DIR/zen-browser-backup.zip"
    local main_directory="$HOME/.zen"
    
    # Handle restore operation
    # -----------------------
    if [[ "$restore" == true ]]; then
        log -f "Restore mode: checking for backup"
        # Check if backup exists
        if [[ ! -f "$backup_file_name" ]]; then
            log -e "No backup file found at $backup_file_name, cannot restore"
            return 1
        fi
        
        log -f "Restoring zen browser from $backup_file_name to $main_directory"
        ensure_directory "$main_directory"
        
        # Extract the backup to the main directory
        log -f "Extracting backup archive"
        unzip -q "$backup_file_name" -d "$main_directory"
        if [ $? -ne 0 ]; then
            log -e "Failed to restore zen browser"
            return 1
        fi
        
        log -f "Restore completed"
        return 0
    fi
    
    # Proceed with backup operation
    # ----------------------------
    log -f "Starting backup operation"
    
    log -f "Ensuring backup directory exists"
    ensure_zsh_backup_dir
    if [ $? -ne 0 ]; then
        log -e "Failed to create backup directory"
        return 1
    fi
    
    # Change working directory for relative paths
    # ------------------------------------------
    log -f "Changing to source directory: $main_directory"
    # Save original directory before changing it
    local original_dir="$(pwd)"
    # from here on we will work in main_directory
    cd "$main_directory" || { log -e "Failed to change directory to $main_directory"; return 1; }
    
    # Create backup archive
    # --------------------
    local temp_backup_file="/tmp/zen-browser-backup.zip"
    log -f "Backing up zen browser from $(pwd) to $temp_backup_file"
    # Zip all files in main_directory excluding specified paths
    zip -qr "$temp_backup_file" . -x "zen/*" -x "*.tar.gz" -x "*.zip" -x "*/storage/**"
    if [ $? -ne 0 ]; then
        # Restore original directory before exit
        cd "$original_dir"
        log -e "Failed to backup zen browser"
        [ -f "$temp_backup_file" ] && rm "$temp_backup_file"
        return 1
    fi
    
    # Finalize backup file
    # -------------------
    log -f "Moving temporary backup file to final location: $temp_backup_file -> $backup_file_name"
    [ -f "$backup_file_name" ] && rm "$backup_file_name"
    mv "$temp_backup_file" "$backup_file_name"
    
    log -f "Backup completed"
    
    # Restore original directory only if we changed it
    cd "$original_dir"
    return 0
}
