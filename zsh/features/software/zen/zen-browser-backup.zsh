require_once "$LIB_PATH/log.zsh"
require_once  "../../utils/ensure_zsh_backup_dir.zsh"

# Helper function for creating backup
function _zen_browser_backup_create() {
    local output_file="$1"
    local backup_all="$2"
    local main_directory="$3"
    
    # Save original directory before changing it
    local original_dir="$(pwd)"
    # from here on we will work in main_directory
    cd "$main_directory" || { log -e "Failed to change directory to $main_directory"; return 1; }
    
    local temp_backup_file="/tmp/$(basename "$output_file")"
    log -f "Backing up zen browser from $(pwd) to $temp_backup_file"
    
    # Create backup archive
    if [[ "$backup_all" == true ]]; then
        # Backup everything with no exclusions
        log -f "Creating complete backup (no exclusions)"
        zip -qr "$temp_backup_file" .
    else
        # Regular backup with exclusions
        log -f "Creating regular backup (with exclusions)"
        zip -qr "$temp_backup_file" . -x "zen/*" -x "*.tar.gz" -x "*.zip" -x "*/storage/**"
    fi
    
    if [ $? -ne 0 ]; then
        cd "$original_dir"
        log -e "Failed to backup zen browser"
        [ -f "$temp_backup_file" ] && rm "$temp_backup_file"
        return 1
    fi
    
    # Finalize backup file
    log -f "Moving temporary backup file to final location: $temp_backup_file -> $output_file"
    [ -f "$output_file" ] && rm "$output_file"
    mv "$temp_backup_file" "$output_file"
    
    # Restore original directory
    cd "$original_dir"
    return 0
}

# Helper function for restoring backup
function _zen_browser_backup_restore() {
    local input_file="$1"
    local is_complete_backup="$2"
    local target_dir="$3"
    
    ensure_directory "$target_dir"
    
    # For complete backups, clean everything first
    if [[ "$is_complete_backup" == true ]]; then
        log -f "Complete backup detected - removing all files in target directory before restore"
        rm -rf "${target_dir:?}"/* 2>/dev/null
    else
        log -f "Regular backup detected - existing excluded files will be preserved"
    fi
    
    # Extract the backup to the target directory
    log -f "Extracting backup archive to $target_dir"
    unzip -q "$input_file" -d "$target_dir"
    if [ $? -ne 0 ]; then
        log -e "Failed to restore zen browser"
        return 1
    fi
    
    return 0
}

function zen-browser-backup() {
    # Parse arguments
    # --------------
    log -f "Parsing arguments"
    local restore=false
    local backup_all=false
    local custom_backup_dir=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r|--restore)
                restore=true
                shift
                ;;
            -a|--all)
                backup_all=true
                shift
                ;;
            -f|--file-dir)
                if [[ -n "$2" && "$2" != -* ]]; then
                    custom_backup_dir="$2"
                    shift 2
                else
                    log -e "Error: -f|--file-dir option requires a directory path argument"
                    return 1
                fi
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Setup variables
    # --------------
    log -f "Setting up variables"
    local backup_suffix=""
    [[ "$backup_all" == true ]] && backup_suffix="-complete"
    local backup_file_name=""
    
    # Set backup file location based on whether a custom directory was provided
    if [[ -n "$custom_backup_dir" ]]; then
        # Ensure custom backup directory exists
        if [[ ! -d "$custom_backup_dir" ]]; then
            log -f "Creating custom backup directory: $custom_backup_dir"
            mkdir -p "$custom_backup_dir" || {
                log -e "Failed to create custom backup directory: $custom_backup_dir"
                return 1
            }
        fi
        backup_file_name="$custom_backup_dir/zen-browser-backup${backup_suffix}.zip"
    else
        # Use default backup directory
        backup_file_name="$ZSH_BACKUP_DIR/zen-browser-backup${backup_suffix}.zip"
    fi
    
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
        
        # Determine if this is a complete backup from filename
        local is_complete_backup=false
        [[ "$backup_file_name" == *"-complete.zip" ]] && is_complete_backup=true
        
        # Restore the backup
        _zen_browser_backup_restore "$backup_file_name" "$is_complete_backup" "$main_directory"
        if [ $? -ne 0 ]; then
            log -e "Backup restore failed"
            return 1
        fi
        
        log -f "Restore completed"
        return 0
    fi
    
    # Proceed with backup operation
    # ----------------------------
    log -f "Starting backup operation"
    
    # Only ensure default backup directory if we're using it
    if [[ -z "$custom_backup_dir" ]]; then
        log -f "Ensuring default backup directory exists"
        ensure_zsh_backup_dir
        if [ $? -ne 0 ]; then
            log -e "Failed to create backup directory"
            return 1
        fi
    fi
    
    # Create the backup
    _zen_browser_backup_create "$backup_file_name" "$backup_all" "$main_directory"
    if [ $? -ne 0 ]; then
        log -e "Backup creation failed"
        return 1
    fi
    
    log -f "Backup completed"
    return 0
}
