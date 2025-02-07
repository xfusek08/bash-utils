require_once "$LIB_PATH/log.zsh"

require_once "_gnome_config_locate_backup.zsh"

function gnome-config-backup() {
    local backup_file_path="$(_gnome_config_locate_backup)"
    log -f "Backing up gnome config to $backup_file_path"
    dconf dump / >"$backup_file_path"
}