require_once "$ZSH_SCRIPTING_DIRECTORY/features/zinit.zsh"

# Reload on alt + f5 shortcut
#   - https://www.reddit.com/r/zsh/comments/13lj5x7/comment/jkr3nsc/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
#   - https://chatgpt.com/share/677277af-5d60-8004-b5ac-6212cbdd0345

exec-zsh() {
    # Pretty info that zsh is restarting
    echo -e "\033[1;33m󰑓 Restarting zsh...\033[0m"
    zle -I
    exec zsh <$TTY
}

alias reload-zsh=exec-zsh

zle -N exec-zsh
bindkey "^[[15;3~" exec-zsh # Alt + f5
