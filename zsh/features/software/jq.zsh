# no-compile

require_once "$LIB_PATH/log.zsh"

# Ensure that jq command is available

if ! command -v jq >/dev/null; then
    log -w "jq command not found, installing"
    sudo nala install jq
fi
