alias bat="batcat --paging=always --italic-text=always --color=always --decorations=always --wrap=never"

function _bat_watch_render() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        batcat --color=always --style=full "$file"
    else
        echo "Waiting for $file..."
    fi
}

function bat-watch() {
    local thisFile="$(realpath "${(%):-%x}")"
    local file="$(realpath "$1")"
    local delay="${2:-1}"
    watch -c -n "$delay" "zsh -c 'echo \"$thisFile\"; source $thisFile; _bat_watch_render \"$file\"'"
}
