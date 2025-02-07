require_once "$LIB_PATH/log.zsh"

function ensure_zsh_backup_dir() {
    # check if ZSH_BACKUP_DIR is valid directory in if it is not then tries to crete it
    if [[ ! -d "$ZSH_BACKUP_DIR" ]]; then
        log -w "Backup directory $ZSH_BACKUP_DIR does not exist, creating it"
        mkdir -p "$ZSH_BACKUP_DIR"
        local error_code=$?
        if [[ ! -d "$ZSH_BACKUP_DIR" ]]; then
            log -e "Backup directory $ZSH_BACKUP_DIR could not be created"
            return $error_code
        fi
    fi
    return 0
}
