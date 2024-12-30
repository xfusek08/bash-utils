
if [[ -z "$ZSH_SCRIPTING_DIRECTORY" ]]; then
    echo "Error: ZSH_SCRIPTING_DIRECTORY is not defined" >&2
    exit 1
fi

ZSH_REQUIRE_ONCE_COMMAND="${ZSH_REQUIRE_ONCE_COMMAND:-$ZSH_SCRIPTING_DIRECTORY/core/require_once.zsh}" # if not set, set it to default
ZSH_REQUIRE_ONCE_COMMAND=$(realpath "$ZSH_REQUIRE_ONCE_COMMAND")
ZSH_LOADER_COMMAND_SOURCE="$ZSH_SCRIPTING_DIRECTORY/core/run_loader.zsh"
CORE_PATH=$(realpath "$ZSH_SCRIPTING_DIRECTORY/core")
LIB_PATH=$(realpath "$ZSH_SCRIPTING_DIRECTORY/lib")
ZSH_BOOTSTRAP_PATH="$ZSH_SCRIPTING_DIRECTORY/core/bootstrap.zsh"

# if require_once command does not exists
if ! declare -f require_once > /dev/null; then
    # echo "${(%):-%x}: require_once command not found" >&2
    # if file does not exists, throw an error
    if [[ ! -f "$ZSH_REQUIRE_ONCE_COMMAND" ]]; then
        echo "Error: require_once script $ZSH_REQUIRE_ONCE_COMMAND does not exist" >&2
        exit 1
    fi
    
    source "$ZSH_REQUIRE_ONCE_COMMAND"
    
    # if require_once command does not exists throw an error
    if ! declare -f require_once > /dev/null; then
        echo "Error: require_once command not found after sourcing $ZSH_REQUIRE_ONCE_COMMAND" >&2
        exit 1
    fi
fi

require_once "$LIB_PATH/log.zsh"

require_once "$ZSH_LOADER_COMMAND_SOURCE"

log -d "Bootstrap script loaded\n \
    ZSH_SCRIPTING_DIRECTORY        = $ZSH_SCRIPTING_DIRECTORY\n \
    ZSH_BOOTSTRAP_PATH             = $ZSH_BOOTSTRAP_PATH\n \
    ZSH_LOADER_COMMAND_SOURCE      = $ZSH_LOADER_COMMAND_SOURCE\n \
    ZSH_REQUIRE_ONCE_COMMAND       = $ZSH_REQUIRE_ONCE_COMMAND\n \
    CORE_PATH                      = $CORE_PATH\n \
    LIB_PATH                       = $LIB_PATH"
