# Create vi and vim aliases only when nvim is available
if command -v nvim &> /dev/null; then
    alias vi='nvim'
    alias vim='nvim'
fi
