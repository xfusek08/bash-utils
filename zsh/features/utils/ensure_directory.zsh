
function ensure_directory() {
    local directory=$1
    if [ ! -d $directory ]; then
        echo "creating directory $directory"
        mkdir -p $directory
    fi
}
