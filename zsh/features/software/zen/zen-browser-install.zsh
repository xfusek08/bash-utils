require_once '../../utils/ensure_directory.zsh'
require_once '../jq.zsh'

function zen-browser-install() {
    local original_pwd=$(pwd)
    
    # prepare directories
    # -------------------
    
    local main_directory="$HOME/.zen"
    local install_directory="$main_directory/zen"
    local backup_file="$main_directory/zen_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    ensue_directory "$main_directory"
    ensure_directory "$install_directory"
    
    # Local functions
    # ---------------
    
    local install_tarball() {
        local tarball_url="$1"
        local target_directory="$2"
        echo "Installing Zen tarball \"$tarball_url\" into \"$target_directory\""
        tar -xJf "$temp_tarball" -C "$target_directory"
    }
    
    local clear_install_directory() {
        echo "Clearing install directory"
        rm -rf "$install_directory"
        ensure_directory "$install_directory"
    }
    
    local revert_installation() {
        if [ ! -f "$backup_file" ]; then
            echo "No backup file found at $backup_file, cannot revert"
            return 1
        fi
        echo "Reverting installation using backup at $backup_file"
        clear_install_directory
        install_tarball "$backup_file" "$main_directory"
    }
    
    # Download latest Zen release tarball
    # -----------------------------------
    
    echo "Checking for latest Zen release"
    local tarball_url=$(curl -s https://api.github.com/repos/zen-browser/desktop/releases/latest | jq -r '.assets[] | select(.name=="zen.linux-x86_64.tar.xz") | .browser_download_url')
    echo "Downloading Zen from: $tarball_url"
    local temp_tarball=$(mktemp "/tmp/zen.XXXXXX.tar.xz")
    wget -O "$temp_tarball" "$tarball_url"
    if [ $? -ne 0 ]; then
        echo "Failed to download Zen tarball"
        return 1
    fi
    
    # Create backup of existing zen installation
    # ------------------------------------------
    
    if [ -n "$(ls -A "$install_directory")" ]; then
        echo "Backing up existing Zen installation into $backup_file"
        tar -czf "$backup_file" -C "$install_directory" .
        clear_install_directory
    fi
    
    # Unpacking the downloaded tarball
    # ---------------------------------
    
    echo "Extracting Zen tarball"
    install_tarball "$temp_tarball" "$main_directory"
    
    # Cleanup temporary tarball
    # -------------------------
    
    rm -f "$temp_tarball"
    
    # Check if extraction was successful
    # -----------------------------------
    
    # check if there is content in install directory
    if [ -z "$(ls -A "$install_directory")" ]; then
        echo "Extraction failed, reverting installation"
        revert_installation
        return 1
    fi
    echo "Extraction completed"
    
    # Register zen executable
    # -----------------------

    echo "Registering Zen executable"
    ensure_directory "$HOME/.local/bin"
    # remove existing link if it exists
    if [ -L "$HOME/.local/bin/zen" ]; then
        rm -f "$HOME/.local/bin/zen"
    fi
    ln -sf "$install_directory/zen" "$HOME/.local/bin/zen"
    
    # Create desktop icon
    # -------------------

    echo "Creating desktop icon for Zen Browser"
    ensure_directory "$HOME/.local/share/applications"
    tee "$HOME/.local/share/applications/zen.desktop" >/dev/null <<EOF
[Desktop Entry]
Version=1.0
Name=Zen Browser
Comment=Experience tranquillity while browsing the web without people tracking you!
GenericName=Web Browser
Keywords=Internet;WWW;Browser;Web;Explorer
Exec=zen
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=$install_directory/zen/browser/chrome/icons/default/default128.png
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
EOF

    # Finalize installation
    # ---------------------
    
    echo "Zen installation process completed"
    cd "$original_pwd"
}
