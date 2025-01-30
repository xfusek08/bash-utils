# Check if entr is already installed
if command -v entr >/dev/null 2>&1; then
    return 0
fi

function _install_entr() {
    echo "entr not found. Installing from source..."

    # Check for required build tools
    for tool in git make cc; do
        if ! command -v $tool >/dev/null 2>&1; then
            echo "Error: Required tool '$tool' is not installed"
            return 1
        fi
    done

    # Use ~/.entr as installation directory
    INSTALL_DIR="$HOME/.entr"

    # Store original directory
    ORIGINAL_PWD=$(pwd)

    # Check if directory exists and create if needed
    if [ ! -d "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
    fi

    cd "$INSTALL_DIR" || return 1

    # Clone and build entr, but only if not already cloned
    if [ ! -d "$INSTALL_DIR/entr" ]; then
        if git clone https://github.com/eradman/entr.git; then
            cd entr || { cd "$ORIGINAL_PWD"; return 1; }
            ./configure
            make test
            sudo make install
            echo "entr installed successfully"
        else
            echo "Failed to clone entr repository"
            cd "$ORIGINAL_PWD"
            return 1
        fi
    else
        echo "entr source already exists in $INSTALL_DIR/entr"
        cd entr || { cd "$ORIGINAL_PWD"; return 1; }
        git pull
        ./configure
        make test
        sudo make install
        echo "entr updated successfully"
    fi

    cd "$ORIGINAL_PWD"
    return 0
}

# Only run installation if entr is not found
if ! command -v entr >/dev/null 2>&1; then
    _install_entr || echo "Failed to install entr"
fi
