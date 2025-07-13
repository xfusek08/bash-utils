if ! command -v zoxide &> /dev/null; then
    echo "Installing zoxide..."
    cargo install zoxide
else
    echo "zoxide is already installed"
fi
