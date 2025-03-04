require_once "../rust/cargo.zsh"

function install_fnm() {
    cargo install fnm
    fnm completions --shell zsh > "$ZSH_SCRIPTING_DIRECTORY/completions/_fnm"
    reload_completions
}
