require_once "../zinit.zsh"
require_once "./zsh-recompile.zsh"

# Recompile and reload on Shift+Alt+F5 shortcut
zle -N zsh-recompile
bindkey "^[[15;4~" zsh-recompile # Shift + Alt + F5
