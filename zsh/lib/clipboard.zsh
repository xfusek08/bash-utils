
function detect-clipboard() {
    emulate -L zsh

    function clipcopy() { cat "${1:-/dev/stdin}" | wl-copy &>/dev/null &; }
    function clippaste() { wl-paste --no-newline; }
}

# Call detect-clipboard to set up the clipboard functions
detect-clipboard