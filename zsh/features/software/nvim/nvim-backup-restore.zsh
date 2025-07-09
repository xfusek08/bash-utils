require_once "$LIB_PATH/log.zsh"
require_once "../../utils/ensure_directory.zsh"
require_once "./nvim-backup.zsh"
require_once "./nvim-utils.zsh"

function nvim-restore-from-zip() {
    local zip_file="$1"
    
    if [ ! -f "$zip_file" ]; then
        log -e "Backup file not found: $zip_file"
        return 1
    fi
    
    log -f "Restoring neovim configuration from $zip_file"
    
    # Remove existing nvim directories
    remove_nvim_directories
    
    # Extract backup
    unzip -q "$zip_file" -d "$HOME/"
    
    if [ $? -ne 0 ]; then
        log -e "Failed to extract backup from $zip_file"
        return 1
    fi
    
    log -f "Neovim configuration restored successfully"
    return 0
}

function nvim-backup-restore() {
    local backup_file
    backup_file=$(ensure_nvim_backup_file)
    
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Create temporary backup before restoration
    local temp_backup
    temp_backup=$(nvim-backup -t)
    local backup_result=$?
    
    if [ $backup_result -ne 0 ]; then
        log -e "Failed to create temporary backup before restoration"
        return 1
    fi
    
    log -f "Created temporary backup at $temp_backup"
    
    # Attempt restoration
    if nvim-restore-from-zip "$backup_file"; then
        log -f "Restoration completed successfully"
        rm -f "$temp_backup"
        return 0
    else
        log -e "Restoration failed, attempting to restore from temporary backup"
        if nvim-restore-from-zip "$temp_backup"; then
            log -f "Successfully restored from temporary backup"
            rm -f "$temp_backup"
            return 1
        else
            log -e "Failed to restore from temporary backup"
            log -w "Your original neovim configuration is preserved in: $temp_backup"
            log -w "You can manually restore it using: nvim-restore-from-zip \"$temp_backup\""
            return 1
        fi
    fi
}
