require_once '../../utils/ensure_directory.zsh'
require_once '../../utils/get_github_release_asset_url.zsh'
require_once '../../utils/download_and_extract.zsh'

function lazygit-install() {
    local original_pwd=$PWD
    
    # prepare directories
    # -------------------
    local main_directory="$HOME/.lazygit"
    local install_directory="$main_directory/lazygit"
    
    ensure_directory "$main_directory"
    ensure_directory "$install_directory"
    
    # Download latest lazygit release tarball
    # --------------------------------------
    echo "Checking for latest lazygit release"
    local tarball_url=$(get_github_release_asset_url "jesseduffield/lazygit" "lazygit_.*_Linux_x86_64[.]tar[.]gz$")
    if [[ -z "$tarball_url" ]]; then
        echo "Failed to find lazygit tarball download URL"
        return 1
    fi
    
    echo "Downloading lazygit from: $tarball_url"
    
    # Clear existing installation
    # --------------------------
    echo "Clearing existing lazygit installation directory"
    rm -rf "$install_directory"
    ensure_directory "$install_directory"
    
    # Download and extract tarball
    # ---------------------------
    echo "Downloading and extracting lazygit tarball"
    if ! download_and_extract "$tarball_url" "$install_directory"; then
        echo "Failed to download and extract lazygit tarball"
        return 1
    fi
    
    # Check if extraction was successful
    # ---------------------------------
    if [[ -z $(ls -A "$install_directory" 2>/dev/null) ]]; then
        echo "Extraction failed"
        return 1
    fi
    echo "Extraction completed"
    
    # Register lazygit executable
    # --------------------------
    echo "Registering lazygit executable"
    ensure_directory "$HOME/.local/bin"
    [[ -L "$HOME/.local/bin/lazygit" ]] && rm -f "$HOME/.local/bin/lazygit"
    ln -sf "$install_directory/lazygit" "$HOME/.local/bin/lazygit"
    
    # Finalize installation
    # --------------------
    echo "Lazygit installation process completed"
    cd "$original_pwd"
}
