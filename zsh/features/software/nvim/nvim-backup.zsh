require_once "$LIB_PATH/log.zsh"
require_once '../../utils/ensure_directory.zsh'
require_once "./nvim-utils.zsh"


function nvim-backup() {
    local temp_only=false
    
    # Parse flags
    if [[ "$1" == "-t" || "$1" == "--temp" ]]; then
        temp_only=true
        shift
    fi
    
    ensure_directory "$ZSH_BACKUP_DIR"
    if [ $? -ne 0 ]; then
        log -e "Failed to create backup directory"
        return 1
    fi
    
    local backup_file_name="$ZSH_BACKUP_DIR/nvim-backup.zip"
    local temp_backup_dir
    temp_backup_dir=$(mktemp -d)
    
    if $temp_only; then
        log -f "Creating temporary neovim backup"
    else
        log -f "Backing up neovim configuration to $backup_file_name"
    fi
    
    # Check if any directories exist
    if ! nvim-directories-exist; then
        log -w "No neovim directories found to backup"
        rm -rf "$temp_backup_dir"
        return 0
    fi
    
    # Array of relative paths to backup
    local paths_to_backup=(
        ".config/nvim"
        ".local/share/nvim"
        ".local/state/nvim"
        ".cache/nvim"
    )
    
    local directories_copied=0
    
    for relative_path in "${paths_to_backup[@]}"; do
        local full_path="$HOME/$relative_path"
        if [ -d "$full_path" ]; then
            # Ensure the directory exists in the temp backup directory
            mkdir -p "$temp_backup_dir/$(dirname "$relative_path")"
            cp -r "$full_path" "$temp_backup_dir/$relative_path"
            log -f "Copied $full_path to $temp_backup_dir/$relative_path"
            directories_copied=$((directories_copied + 1))
        else
            log -w "Directory $full_path does not exist, skipping"
        fi
    done
    
    if [ $directories_copied -eq 0 ]; then
        log -w "No neovim directories were copied, nothing to backup"
        rm -rf "$temp_backup_dir"
        return 0
    fi
    
    # Create zip from temp directory contents
    local temp_zip_name="nvim-backup-temp.zip"
    local temp_backup_file="$temp_backup_dir/$temp_zip_name"
    log -f "Creating zip file at $temp_backup_file"
    
    # Save current directory and change to temp directory to create zip
    local original_cwd=$(pwd)
    local zip_result
    cd "$temp_backup_dir"
    zip -r "$temp_zip_name" .
    zip_result=$?
    cd "$original_cwd"
    if [ $zip_result -eq 0 ]; then
        log -f "Backup zip file created successfully"
    else
        log -e "Failed to create backup zip file"
        log -e "Zip command returned error code $zip_result"
        log -e "Leaving temporary backup directory at $temp_backup_dir for debugging"
        return 1
    fi
    
    if $temp_only; then
        local output_file="/tmp/nvim-backup-$(date +%Y%m%d-%H%M%S).zip"
        cp "$temp_backup_file" "$output_file"
        rm -rf "$temp_backup_dir"
        echo "$output_file"
        return 0
    fi
    
    # Remove previous backup only after successful creation
    [ -f "$backup_file_name" ] && rm "$backup_file_name"
    
    # Move temporary backup to final location
    cp "$temp_backup_file" "$backup_file_name"
    
    # Clean up temp directory
    rm -rf "$temp_backup_dir"
    
    log -f "Neovim backup completed"
    return 0
}
