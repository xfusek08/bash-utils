require_once '../../utils/ensure_directory.zsh'
require_once '../../utils/get_github_release_asset_url.zsh'
require_once '../../utils/download_and_extract.zsh'

function youtube-music-install() {
    local original_pwd=$PWD
    
    # prepare directories
    # -------------------
    
    local main_directory="$HOME/.youtube-music"
    local install_directory="$main_directory/app"
    local source_directory="$main_directory/source"
    
    ensure_directory "$main_directory"
    ensure_directory "$install_directory"
    ensure_directory "$source_directory"
    
    # Local functions
    # ---------------
    
    local install_appimage() {
        local appimage_url=$1
        local target_directory=$2
        echo "Installing YouTube Music AppImage '$appimage_url' into '$target_directory'"
        local appimage_file="$target_directory/YouTube-Music.AppImage"
        wget -O "$appimage_file" "$appimage_url"
        chmod +x "$appimage_file"
    }
    
    local clear_install_directory() {
        echo "Clearing install directory"
        rm -rf "$install_directory"
        ensure_directory "$install_directory"
    }
    
    local clear_source_directory() {
        echo "Clearing source directory"
        rm -rf "$source_directory"
        ensure_directory "$source_directory"
    }
    
    local install_source() {
        local zipball_url=$1
        local target_directory=$2
        echo "Downloading YouTube Music source code from '$zipball_url'"
        download_and_extract "$zipball_url" "$target_directory" "zip"
    }
    
    # Download latest YouTube Music release info
    # ------------------------------------------
    
    echo "Checking for latest YouTube Music release"
    local appimage_url=$(get_github_release_asset_url "th-ch/youtube-music" "YouTube-Music-.*\\.AppImage$")
    if [[ -z "$appimage_url" ]]; then
        echo "Failed to find AppImage download URL"
        return 1
    fi
    
    # Filter out ARM versions if multiple matches
    if [[ "$appimage_url" == *"arm"* ]]; then
        echo "Found ARM version, looking for x86_64 version"
        appimage_url=$(get_github_release_asset_url "th-ch/youtube-music" "YouTube-Music-.*(?!.*arm).*\\.AppImage$")
        
        if [[ -z "$appimage_url" ]]; then
            echo "Failed to find non-ARM AppImage download URL"
            return 1
        fi
    fi
    
    echo ""
    echo "Downloading YouTube Music from: $appimage_url"
    echo ""
    
    # Extract source code URL - zipball is just another asset
    local temp_json=$(mktemp "/tmp/youtube-music-release.XXXXXX.json")
    curl -s https://api.github.com/repos/th-ch/youtube-music/releases/latest > "$temp_json"
    local zipball_url=$(cat "$temp_json" | jq -r '.zipball_url')
    rm -f "$temp_json"
    
    if [[ -z "$zipball_url" || "$zipball_url" == "null" ]]; then
        echo "Failed to find source code download URL"
        return 1
    fi
    
    echo "Source code URL: $zipball_url"
    echo ""
    
    # Clear existing installations
    # ---------------------------
    
    clear_install_directory
    clear_source_directory
    
    # Download the AppImage
    # --------------------
    
    echo "Downloading YouTube Music AppImage"
    install_appimage "$appimage_url" "$install_directory"
    
    if [[ $? -ne 0 ]]; then
        echo "Failed to download YouTube Music AppImage"
        return 1
    fi
    
    # Check if download was successful
    # -------------------------------
    
    if [[ ! -f "$install_directory/YouTube-Music.AppImage" ]]; then
        echo "Download failed"
        return 1
    fi
    echo "AppImage download completed"
    
    # Download and extract source code
    # --------------------------------
    
    echo "Downloading and extracting source code"
    install_source "$zipball_url" "$source_directory"
    
    if [[ $? -ne 0 ]]; then
        echo "Failed to download source code, but AppImage installation was successful"
    else
        echo "Source code extraction completed"
    fi
    
    # Register YouTube Music executable
    # --------------------------------

    echo "Registering YouTube Music executable"
    ensure_directory "$HOME/.local/bin"
    [[ -L "$HOME/.local/bin/youtube-music" ]] && rm -f "$HOME/.local/bin/youtube-music"
    ln -sf "$install_directory/YouTube-Music.AppImage" "$HOME/.local/bin/youtube-music"
    
    # Create desktop icon
    # ------------------

    echo "Creating desktop icon for YouTube Music"
    ensure_directory "$HOME/.local/share/applications"
    tee "$HOME/.local/share/applications/youtube-music.desktop" >/dev/null <<EOF
[Desktop Entry]
Version=1.0
Name=YouTube Music
Comment=YouTube Music Desktop App
GenericName=Music Player
Keywords=Music;Audio;Player;YouTube;Streaming;
Exec=bash -c '$install_directory/YouTube-Music.AppImage'
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=$source_directory/assets/youtube-music.png
Categories=AudioVideo;Audio;Player;
MimeType=audio/mpeg;audio/mp4;audio/x-vorbis+ogg;audio/x-flac;
StartupNotify=true
StartupWMClass=YouTube Music
EOF

    # Make desktop file executable
    chmod +x "$HOME/.local/share/applications/youtube-music.desktop"

    # Finalize installation
    # --------------------
    
    echo "YouTube Music installation process completed"
    cd "$original_pwd"
}
