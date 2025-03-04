
require_once "cargo.zsh"
require_once "../../reload_completions.zsh"

function update-cargo() {
    rustup update
    rustup completions zsh cargo > $ZSH_COMPLETIONS_DIRECTORY/_cargo
    reload_completions
}
