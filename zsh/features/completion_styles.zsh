zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'     # Bold descriptions
zstyle ':completion:*:messages' format '%d'             # Normal messages
zstyle ':completion:*:warnings' format 'No matches: %d' # Warnings
zstyle ':completion:*' group-name ''                    # Group options by category
