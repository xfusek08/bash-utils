# NVM configuration

# Only when compiling - it does not have to run every shell start

function init_node() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                 # This loads nvm
    [ -s "$NVM_DIR/zsh_completion" ] && \. "$NVM_DIR/zsh_completion" # This loads nvm zsh_completion
}
