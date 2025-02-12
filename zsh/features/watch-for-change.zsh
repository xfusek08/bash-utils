require_once "$SCRIPTS_PATH/ensure-entr.zsh"

# From:
# ".rw-rw-r--  289 petr 11 úno 10:28 -- /home/petr/sw/repo/work/xaver-5-monolith/bundles/xaver/assets/js/admin/themes/xaver/sulu-admin-bundle/components/Toolbar/toolbar.scss"
# To:
# ".rw-rw-r--  289 petr 11 úno 10:28 -- /h/p/s/r/w/x/b/x/a/j/a/t/x/s/c/Toolbar/toolbar.scss"
reduce-path() {
    sed -E 's|/([a-zA-Z0-9-]{4,})|/\1|g; s|/([a-zA-Z0-9-])([a-zA-Z0-9-]{3,})|/\1|g'
}

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

    shift # skip the -- separator

    if [[ -z "$all_files" ]]; then
        echo "Error: No files specified to watch"
        return 1
    fi

    if [[ $# -eq 0 ]]; then
        echo "Error: No command specified after --"
        return 1
    fi

    local to_watch_display=$(printf "$all_files" | tr '\n' '\0' | xargs -0 eza --long --git --color=always)
    
    echo "\nWatching these files:\n"
    while IFS= read -r file; do
        echo "$(echo "$file" | reduce-path)"
    done <<< "$to_watch_display"
    
    echo "\nStarting watch...\n"

    printf "$all_files" | entr -ds "$*"
}
