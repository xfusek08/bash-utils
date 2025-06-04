require_once '../../utils/ensure_directory.zsh'
require_once '../jq.zsh'

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
        local temp_zip=$(mktemp "/tmp/youtube-music-source.XXXXXX.zip")
        wget -O "$temp_zip" "$zipball_url"
        if [[ $? -ne 0 ]]; then
            echo "Failed to download source code"
            rm -f "$temp_zip"
            return 1
        fi
        echo "Extracting source code to '$target_directory'"
        local temp_extract=$(mktemp -d "/tmp/youtube-music-extract.XXXXXX")
        unzip -q "$temp_zip" -d "$temp_extract"
        # Find the root folder (should be the only directory)
        local extracted_dir=$(find "$temp_extract" -maxdepth 1 -type d -not -path "$temp_extract" | head -n 1)
        if [[ -n "$extracted_dir" && -d "$extracted_dir" ]]; then
            # Move contents from the extracted root folder to target directory
            mv "$extracted_dir"/* "$target_directory/" 2>/dev/null
            # Also move hidden files if any
            mv "$extracted_dir"/.* "$target_directory/" 2>/dev/null || true
        fi
        rm -rf "$temp_extract"
        rm -f "$temp_zip"
    }
    
    # Download latest YouTube Music release info
    # ------------------------------------------
    
    echo "Checking for latest YouTube Music release"
    local temp_json=$(mktemp "/tmp/youtube-music-release.XXXXXX.json")
    curl -s https://api.github.com/repos/th-ch/youtube-music/releases/latest > "$temp_json"
    
    if [[ $? -ne 0 ]] || [[ ! -s "$temp_json" ]]; then
        echo "Failed to fetch release information"
        rm -f "$temp_json"
        return 1
    fi
    
    # Extract AppImage URL
    local appimage_url=$(cat "$temp_json" | jq -r '.assets[] | select(.name | test("YouTube-Music-.*\\.AppImage$") and (test("arm") | not)) | .browser_download_url')
    echo ""
    echo "Downloading YouTube Music from: $appimage_url"
    echo ""
    
    if [[ -z "$appimage_url" || "$appimage_url" == "null" ]]; then
        echo "Failed to find AppImage download URL"
        rm -f "$temp_json"
        return 1
    fi
    
    # Extract source code URL
    local zipball_url=$(cat "$temp_json" | jq -r '.zipball_url')
    echo "Source code URL: $zipball_url"
    echo ""
    
    rm -f "$temp_json"
    
    if [[ -z "$zipball_url" || "$zipball_url" == "null" ]]; then
        echo "Failed to find source code download URL"
        return 1
    fi
    
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
