
function is_valid_directory() {
    local directory="$1"
    if [ -d "$directory" ]; then
        return 0
    else
        return 1
    fi
}
