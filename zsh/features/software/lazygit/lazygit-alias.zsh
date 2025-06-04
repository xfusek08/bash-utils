# Create lg alias only when lazygit is available
if command -v lazygit &> /dev/null; then
    alias lg='lazygit'
fi
