require_once "$SCRIPTS_PATH/ensure-entr.zsh"

watch-on-change() {
    local files=()
    local all_files=""
    
    while [[ $# -gt 0 && "$1" != "--" ]]; do
        if [ -d "$1" ]; then
            # For directories, find all files recursively
            all_files+="$(find "$1" -type f)\n"
        else
            # For regular files, add them directly
            all_files+="$1\n"
        fi
        shift
    done
    
    shift  # skip the -- separator
    
    if [[ -z "$all_files" ]]; then
        echo "Error: No files specified to watch"
        return 1
    fi
    
    if [[ $# -eq 0 ]]; then
        echo "Error: No command specified after --"
        return 1
    fi

    printf "$all_files" | entr -ds "$*"
}
