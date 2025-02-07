require_once "$LIB_PATH/log.zsh"

require_once "_gnome_config_locate_backup.zsh"

function gnome-config-restore() {
    local backup_file_path="$(_gnome_config_locate_backup)"
    log -f "Restoring gnome config from $backup_file_path"
    dconf load / <"$backup_file_path"
}
