require_once "install_fnm.zsh"

# if fnm command is not found, then install it
if ! command -v fnm &> /dev/null; then
    install_fnm
fi

eval "$(fnm env --use-on-cd --shell zsh)"

# ensure that node and bun are installed

if ! command -v node &> /dev/null; then
    fnm use 23
    npm install -g bun
fi
