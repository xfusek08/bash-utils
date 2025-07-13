require_once '../../utils/ensure_directory.zsh'

function zed-install() {
    local original_pwd=$PWD
    
    # prepare directories
    # -------------------
    local main_directory="$HOME/.zed"
    # update installation directory to match extracted folder name "zed.app"
    local install_directory="$main_directory/zed.app"
    local backup_file="$main_directory/zed_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    ensure_directory "$main_directory"
    ensure_directory "$install_directory"
    
    # Local functions
    # ---------------
    
    local install_tarball() {
        local tarball_path=$1
        local target_directory=$2
        echo "Installing zed tarball '$tarball_path' into '$target_directory'"
        tar -xzf "$tarball_path" --strip-components=1 -C "$target_directory"
    }
    
    local clear_install_directory() {
        echo "Clearing install directory"
        rm -rf "$install_directory"
        ensure_directory "$install_directory"
    }
    
    local revert_installation() {
        if [[ ! -f "$backup_file" ]]; then
            echo "No backup file found at $backup_file, cannot revert"
            return 1
        fi
        echo "Reverting installation using backup at $backup_file"
        clear_install_directory
        install_tarball "$backup_file" "$install_directory"
    }
    
    # Download latest zed release tarball
    # -----------------------------------
    echo "Checking for latest zed release"
    local tarball_url=$(curl -s https://api.github.com/repos/zed-industries/zed/releases/latest | jq -r '.assets[] | select(.name=="zed-linux-x86_64.tar.gz") | .browser_download_url')
    echo "Downloading zed from: $tarball_url"
    local temp_tarball=$(mktemp "/tmp/zed.XXXXXX.tar.xz")
    wget -O "$temp_tarball" "$tarball_url"
    if [[ $? -ne 0 ]]; then
        echo "Failed to download zed tarball"
        return 1
    fi
    
    # Create backup of existing zed installation
    # ------------------------------------------
    if [[ -n $(ls -A "$install_directory" 2>/dev/null) ]]; then
        echo "Backing up existing zed installation into $backup_file"
        tar -czf "$backup_file" -C "$install_directory" .
        clear_install_directory
    fi
    
    # Unpack the downloaded tarball
    # ---------------------------------
    echo "Extracting zed tarball"
    install_tarball "$temp_tarball" "$install_directory"
    
    # Cleanup temporary tarball
    # -------------------------
    rm -f "$temp_tarball"
    
    # Validate extraction
    # -----------------------------------
    if [[ -z $(ls -A "$install_directory" 2>/dev/null) ]]; then
        echo "Extraction failed, reverting installation"
        revert_installation
        return 1
    fi
    echo "Extraction completed"
    
    # Register zed executable
    # -----------------------
    echo "Registering zed executable"
    ensure_directory "$HOME/.local/bin"
    [[ -L "$HOME/.local/bin/zed" ]] && rm -f "$HOME/.local/bin/zed"
    ln -sf "$install_directory/bin/zed" "$HOME/.local/bin/zed"
    
    # Copy entire 'share' directory to ~/.local/share to preserve subdirectories and files
    echo "Installing shared resources from zed.app/share to ~/.local/share"
    ensure_directory "$HOME/.local/share"
    cp -rf "$install_directory/share/." "$HOME/.local/share/"
    
    # Finalize installation
    # ---------------------
    echo "Zed installation process completed"
    cd "$original_pwd"
}
