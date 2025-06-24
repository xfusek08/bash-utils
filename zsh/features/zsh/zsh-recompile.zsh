require_once "./zsh-reload.zsh"

function zsh-recompile() {
    echo -e "\033[1;36m🔄 Recompiling zsh features...\033[0m"
    rm -f "$ZSH_COMPILED_FEATURES_FILENAME"
    zsh-reload
}
