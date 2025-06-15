require_once '../../utils/ensure_directory.zsh'
require_once '../../utils/get_github_release_asset_url.zsh'
require_once '../../utils/download_and_extract.zsh'
require_once "./zen-browser-backup.zsh"
require_once "$LIB_PATH/log.zsh"

function zen-browser-install() {
    # prepare directories
    # -------------------
    log -f "prepare directories"
    local main_directory="$HOME/.zen"
    local install_directory="$main_directory/zen"
    
    ensure_directory "$main_directory"
    ensure_directory "$install_directory"
    
    # Download latest Zen release tarball
    # -----------------------------------
    log -f "Checking github metadata for latest Zen release"
    local tarball_url=$(get_github_release_asset_url "zen-browser/desktop" "linux-x86_64.tar.xz")
    if [[ -z "$tarball_url" ]]; then
        log -f "Failed to find Zen tarball download URL"
        return 1
    fi
    log -f "Found latest Zen tarball URL: $tarball_url"
    
    # Create backup of existing zen installation
    # ------------------------------------------
    log -f "Create backup of existing zen installation in: $install_directory"
    if [[ -n $(ls -A "$install_directory" 2>/dev/null) ]]; then
        log -f "Backing up existing Zen installation"
        zen-browser-backup  # No arguments means perform backup
        if [ $? -ne 0 ]; then
            log -f "Backup failed, aborting installation"
            return 1
        fi
        log -f "Clearing install directory"
        rm -rf "$install_directory"
        ensure_directory "$install_directory"
    else
        log -f "No existing Zen installation found, proceeding with installation."
    fi
    
    # Download and extract tarball
    # ----------------------------
    log -f "Downloading and extracting Zen tarball from: $tarball_url"
    if ! download_and_extract "$tarball_url" "$install_directory"; then
        log -f "Failed to download and extract Zen tarball"
        return 1
    fi
    
    # Check if extraction was successful
    # -----------------------------------
    log -f "Checking if extraction was successful"
    if [[ -z $(ls -A "$install_directory" 2>/dev/null) ]]; then
        # There is content in install directory...
        log -f "Extraction failed, reverting installation"
        zen-browser-backup -r  # -r flag means restore
        return 1
    fi
    log -f "Extraction completed"
    
    # Cleanup temporary tarball
    # -------------------------
    log -f "Cleaning up temporary tarball: $temp_tarball"
    rm -f "$temp_tarball"
    
    # Register zen executable
    # -----------------------
    log -f "Registering Zen executable"
    ensure_directory "$HOME/.local/bin"
    [[ -L "$HOME/.local/bin/zen" ]] && rm -f "$HOME/.local/bin/zen"
    ln -sf "$install_directory/zen" "$HOME/.local/bin/zen"
    
    # Create desktop icon
    # -------------------
    log -f "Creating desktop icon for Zen Browser"
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
Icon=$install_directory/browser/chrome/icons/default/default128.png
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
EOF

    # Finalize installation
    # ---------------------
    log -f "Zen installation process completed"
}
