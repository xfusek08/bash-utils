# Start time measurement
zmodload zsh/datetime
shell_start=$EPOCHREALTIME

# Function to display loading time
function display_loading_time() {
    local end_time=$EPOCHREALTIME
    local taken=$(printf "%.2f" $(( end_time - ${1} )))
    print -P "%B%F{green}󱐋 Shell loaded in ${taken}s%f%b"
}

ZSH_SCRIPTING_DIRECTORY=${ZSH_SCRIPTING_DIRECTORY:-"$HOME/sw/repo/personal/bash-utils/zsh"}
ZSH_SCRIPTING_BOOTSTRAP="$ZSH_SCRIPTING_DIRECTORY/core/bootstrap.zsh"

# if loader does not exist, create it
if [ -f "$ZSH_SCRIPTING_BOOTSTRAP" ]; then
    source "$ZSH_SCRIPTING_BOOTSTRAP"
    run_loader "$ZSH_SCRIPTING_DIRECTORY"
fi

# Initialize completion
autoload -U compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'

# Display loading time at the end
display_loading_time $shell_start
