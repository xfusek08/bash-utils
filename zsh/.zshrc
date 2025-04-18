# zmodload zsh/zprof

# Start time measurement
zmodload zsh/datetime
shell_start=$EPOCHREALTIME

# Function to display loading time
function display_loading_time() {
    local end_time=$EPOCHREALTIME
    local taken=$(printf "%.2f" $((end_time - ${1})))
    print -P "%B%F{green}󱐋 Shell loaded in ${taken}s%f%b"
}

# ZSH_DEBUG=true
# ZSH_SCRIPTING_LOG_LEVEL=INFO
ZSH_BACKUP_DIR="$HOME/DiskGoogle/Zalohy"
ZSH_SCRIPTING_DIRECTORY=${ZSH_SCRIPTING_DIRECTORY:-"$HOME/sw/repo/personal/bash-utils/zsh"}
ZSH_SCRIPTING_BOOTSTRAP="$ZSH_SCRIPTING_DIRECTORY/core/bootstrap.zsh"

# if loader does not exist, create it
if [ -f "$ZSH_SCRIPTING_BOOTSTRAP" ]; then
    source "$ZSH_SCRIPTING_BOOTSTRAP"
    $SCRIPTS_PATH/ensure_directory.zsh $1 "$ZSH_SCRIPTING_DIRECTORY/completions"
    
    # Add completions directory to fpath
    fpath=("$ZSH_SCRIPTING_DIRECTORY/completions" $fpath)
    run_loader
    autoload -Uz compinit
fi

# Display loading time at the end
display_loading_time $shell_start
