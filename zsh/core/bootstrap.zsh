if [[ -z "$ZSH_SCRIPTING_DIRECTORY" ]]; then
    echo "Error: ZSH_SCRIPTING_DIRECTORY is not defined" >&2
    exit 1
fi

# Set up global paths:

ZSH_REQUIRE_ONCE_COMMAND="${ZSH_REQUIRE_ONCE_COMMAND:-$ZSH_SCRIPTING_DIRECTORY/core/require_once.zsh}" # if not set, set it to default
ZSH_REQUIRE_ONCE_COMMAND=$(realpath "$ZSH_REQUIRE_ONCE_COMMAND")
ZSH_LOADER_COMMAND_SOURCE="$ZSH_SCRIPTING_DIRECTORY/core/run_loader.zsh"
CORE_PATH=$(realpath "$ZSH_SCRIPTING_DIRECTORY/core")
LIB_PATH=$(realpath "$ZSH_SCRIPTING_DIRECTORY/lib")
SCRIPTS_PATH=$(realpath "$ZSH_SCRIPTING_DIRECTORY/scripts")
FEATURES_PATH=$(realpath "$ZSH_SCRIPTING_DIRECTORY/features")
ZSH_BOOTSTRAP_PATH="$ZSH_SCRIPTING_DIRECTORY/core/bootstrap.zsh"
ZSH_COMPILED_FEATURES_FILENAME="$ZSH_SCRIPTING_DIRECTORY/compiled_features.zsh"
ZSH_COMPLETIONS_DIRECTORY=$ZSH_SCRIPTING_DIRECTORY/completions

ZSH_BUNNER_SCRIPTS_DIRECTORY="${ZSH_BUNNER_DIRECTORY:-$(realpath "$ZSH_SCRIPTING_DIRECTORY/../bunner-commands")}"
ZSH_BUNNER_RUN_COMMAND="${ZSH_BUNNER_RUN_COMMAND:-$(realpath "$ZSH_SCRIPTING_DIRECTORY/../bunner/run")}"

ZSH_BACKUP_DIR="${ZSH_BACKUP_DIR:-$HOME/.backups}"

# Set up debug mode and log level:

ZSH_DEBUG="${ZSH_DEBUG:-false}"
ZSH_SCRIPTING_LOG_LEVEL="${ZSH_SCRIPTING_LOG_LEVEL:-null}"
# if log level is not set, set it to null
if [[ "$ZSH_SCRIPTING_LOG_LEVEL" == "null" ]]; then
    # if debug
    if [[ "$ZSH_DEBUG" == "true" ]]; then
        ZSH_SCRIPTING_LOG_LEVEL="DEBUG"
    else
        ZSH_SCRIPTING_LOG_LEVEL="WARNING"
    fi
fi

# if require_once command does not exists, source it
if ! declare -f require_once >/dev/null; then
    # echo "${(%):-%x}: require_once command not found" >&2
    # if file does not exists, throw an error
    if [[ ! -f "$ZSH_REQUIRE_ONCE_COMMAND" ]]; then
        echo "Error: require_once script $ZSH_REQUIRE_ONCE_COMMAND does not exist" >&2
        exit 1
    fi

    source "$ZSH_REQUIRE_ONCE_COMMAND"

    # if require_once command does not exists throw an error
    if ! declare -f require_once >/dev/null; then
        echo "Error: require_once command not found after sourcing $ZSH_REQUIRE_ONCE_COMMAND" >&2
        exit 1
    fi
fi

require_once "$LIB_PATH/log.zsh"

require_once "$ZSH_LOADER_COMMAND_SOURCE"

log -d "Bootstrap script loaded\n \
    CORE_PATH                      = $CORE_PATH\n \
    FEATURES_PATH                  = $FEATURES_PATH\n \
    LIB_PATH                       = $LIB_PATH\n \
    SCRIPTS_PATH                   = $SCRIPTS_PATH" \
    ZSH_BACKUP_DIR                 = $ZSH_BACKUP_DIR\n \
    ZSH_BOOTSTRAP_PATH             = $ZSH_BOOTSTRAP_PATH\n \
    ZSH_COMPILED_FEATURES_FILENAME = $ZSH_COMPILED_FEATURES_FILENAME\n \
    ZSH_LOADER_COMMAND_SOURCE      = $ZSH_LOADER_COMMAND_SOURCE\n \
    ZSH_REQUIRE_ONCE_COMMAND       = $ZSH_REQUIRE_ONCE_COMMAND\n \
    ZSH_SCRIPTING_DIRECTORY        = $ZSH_SCRIPTING_DIRECTORY\n \
    ZSH_COMPLETIONS_DIRECTORY      = $ZSH_COMPLETIONS_DIRECTORY\n \
    ZSH_BUNNER_SCRIPTS_DIRECTORY   = $ZSH_BUNNER_SCRIPTS_DIRECTORY\n \
    ZSH_BUNNER_RUN_COMMAND         = $ZSH_BUNNER_RUN_COMMAND\n
