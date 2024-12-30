
# Compare if the message level is high enough to be logged
function _should_log() {
        # Define log levels (higher number = higher priority)
    declare -A ZSH_SCRIPTING_LOG_LEVELS=(
        [ERROR]=40
        [WARNING]=30
        [INFO]=20
        [DEBUG]=10
    )

    # Default to WARNING if ZSH_SCRIPTING_LOG_LEVEL not set
    : ${ZSH_SCRIPTING_LOG_LEVEL:=WARNING}

    local msg_level=$1
    local threshold_level=${ZSH_SCRIPTING_LOG_LEVEL}
    
    if [[ ${ZSH_SCRIPTING_LOG_LEVELS[$msg_level]} -ge ${ZSH_SCRIPTING_LOG_LEVELS[$threshold_level]} ]]; then
        return 0
    else
        return 1
    fi
}

# Logs to std error with pretty formatting and colors and time stamp and type ERROR|DEBUG|WARNING
function log() {
    local type="INFO"
    local color="37"
    
    # Parse options
    while getopts "iewdh" opt; do
        case "$opt" in
            i) type="INFO" ; color="37" ;;
            e) type="ERROR" ; color="31" ;;
            w) type="WARNING" ; color="33" ;;
            d) type="DEBUG" ; color="32" ;;
            h) echo "Usage: log [-i|-e|-w|-d] message" ; return 0 ;;
            ?) echo "Invalid option. Usage: log [-i|-e|-w|-d] message" >&2 ; return 1 ;;
        esac
    done
    shift $((OPTIND-1))
    
    # Check if this message should be logged based on level
    if ! _should_log "$type"; then
        return 0
    fi
    
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local color_code="\033[1;${color}m"
    
    echo -e "$timestamp $color_code [$type] $message \033[0m" >&2
}
