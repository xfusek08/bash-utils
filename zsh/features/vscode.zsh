require_once "$ZSH_SCRIPTING_DIRECTORY/features/deb_package_install.zsh"

function install_vscode() {
    local vscode_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    install_deb_package_url "$vscode_url"
}
