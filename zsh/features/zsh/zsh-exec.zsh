
function zsh-exec() {
    # Pretty info that zsh is restarting
    echo -e "\033[1;33m󰑓 Restarting zsh...\033[0m"
    zle -I
    exec zsh <$TTY
}
