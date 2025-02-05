#!/bin/zsh

function run_loader() {
    local input_directory_arg=${1:-"$FEATURES_PATH"} # when not set, run the loaded over the features directory
    local input_directory=$(realpath "$input_directory_arg")

    require_once "$LIB_PATH/is_valid_directory.zsh"

    # if not a valid directory, exit
    if ! is_valid_directory "$input_directory"; then
        log -e "Directory $input_directory does not exist"
        return 1
    fi

    local level=${2:-0} # Level is passed as second argument if not set, set it to 0

    log "Processing directory $input_directory"
    log -d "prepare_loaders.zsh configuration:\n \
        input_directory                = $input_directory\n \
        level                          = $level"

    function list_directories() {
        local directory="$1"
        if ! is_valid_directory "$directory"; then
            log -e "Directory $directory does not exist"
            return ""
        fi
        local command="find $directory -mindepth 1 -maxdepth 1 -type d -exec realpath {} \;"
        log -d "Executing: $command"
        local directories=$(eval $command)
        log -d "$level: Found directories:\n$directories"
        echo $directories
    }

    function list_all_zsh_files() {
        local directory="$1"
        if ! is_valid_directory "$directory"; then
            log -e "Directory $directory does not exist"
            return ""
        fi
        log -d "Executing: ls -f $directory/*.zsh"
        local files=$(ls -1 $directory/*.zsh) 2>/dev/null
        log -d "$level: Found files:\n$files"
        echo $files
    }

    # iterate over directories and recursively call this script for each
    for directory in $(list_directories "$input_directory"); do
        run_loader "$directory" $(($level + 1))
    done

    log -d "Loading files from $input_directory on level $level"

    # require_once all zsh files into current loader file
    for file in $(list_all_zsh_files "$input_directory"); do

        # if file is in CORE_PATH directory or SCRIPTS_PATH directory, skip it
        if [[ "$file" == "$CORE_PATH"* || "$file" == "$SCRIPTS_PATH"* ]]; then
            log -d "Skipping core or scripts file $file"
            continue
        fi

        if [[ "$(basename "$file")" == _* ]]; then
            log -d "Requiring completion file $file"
        else
            log -d "Requiring $file"
        fi
        require_once "$file"
    done
}
