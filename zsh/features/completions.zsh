
require_once "$ZSH_SCRIPTING_DIRECTORY/features/zinit.zsh"
require_once "$ZSH_SCRIPTING_DIRECTORY/features/fzf-tab.zsh"

zinit light zsh-users/zsh-completions

autoload -U compinit && compinit

# Completion config
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case-insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # color completion
zstyle ':completion:*' menu no # no menu selection to work with fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'
