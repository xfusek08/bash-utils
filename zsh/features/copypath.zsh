# Add shortcut "Alt + o" to copy the current path to the clipboard

# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/copypath

# needs sudo nala install wl-clipboard to work
# https://askubuntu.com/a/1370797

require_once "$ZSH_SCRIPTING_DIRECTORY/features/zinit.zsh"
require_once "$ZSH_SCRIPTING_DIRECTORY/lib/clipboard.zsh"

zinit snippet OMZP::copypath

function copypath-widget() {
    copypath
    # zle -I # redraw
}

zle -N copypath-widget

bindkey "^[o" copypath-widget
