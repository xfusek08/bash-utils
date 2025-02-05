#!/bin/zsh

require_once "$CORE_PATH/process_files_to_single_compiled_file.zsh"
require_once "$LIB_PATH/is_valid_directory.zsh"

function load_directories_recursive() {
    local input_directory=$(realpath "$1")
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
        load_directories_recursive "$directory" $(($level + 1))
    done

    log -d "Loading files from $input_directory on level $level"

    # require_once all zsh files into current loader file
    for file in $(list_all_zsh_files "$input_directory"); do
        if [[ "$(basename "$file")" == _* ]]; then
            log -d "Requiring completion file $file"
        else
            log -d "Requiring $file"
        fi
        require_once "$file"
    done
}

function source_and_compile_features() {
    require_once-start_capture
    load_directories_recursive "$FEATURES_PATH"
    local file_list=$(require_once-end-capture)
    process_files_to_single_compiled_file "$file_list" "$ZSH_COMPILED_FEATURES_FILENAME"
    source $SCRIPTS_PATH/on-compilation-finish.zsh
}

function run_loader() {
    # if $ZSH_COMPILED_FEATURES_FILENAME file exists source it
    if [[ -f "$ZSH_COMPILED_FEATURES_FILENAME" ]]; then
        log -d "Sourcing $ZSH_COMPILED_FEATURES_FILENAME"
        source "$ZSH_COMPILED_FEATURES_FILENAME"
    else
        source_and_compile_features
    fi
}
