require_once "$LIB_PATH/log.zsh"

function ensure_directory() {
    local dir="$1"
    log -i "Ensuring directory exists: \"$dir\""
    if [[ ! -d "$dir" ]]; then
        log -w "Directory \"$dir\" does not exist, creating it."
        mkdir -p "$dir"
        local error_code=$?
        if [[ ! -d "$dir" ]]; then
            log -e "Directory \"$dir\" could not be created."
            return $error_code
        fi
    fi
}
