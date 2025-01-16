# Common color definitions and helper functions
WHITE=$'\033[1;37m'
GOLD=$'\033[1;33m'
GREEN=$'\033[1;32m'
RESET=$'\033[0m'

# Helper functions
function _get_user_uid() {
    id -u "$1" 2>/dev/null
}

function _get_group_members() {
    local group=$1
    local show_uid=$2
    getent group "$group" | cut -d: -f4 | tr ',' '\n' | while read -r member; do
        if [[ -n "$member" ]]; then
            [[ "$show_uid" == "true" ]] && local uid="($(_get_user_uid "$member"))"
            echo "$member${uid}"
        fi
    done | paste -sd "," -
}

# PERMISSIONS MANAGEMENT
# --------------------

# Set restricted permissions (rw for user/group, r for others)
# Preserves execute bits only where they already exist
# Usage: perm-restricted <path>
unalias perm-restricted 2>/dev/null
function perm-restricted() {
    find "$1" -type f \
        \( -perm /111 -exec chmod ug+rwx,o-r {} \; \) \
        -o \
        \( ! -perm /111 -exec chmod ug+rw,o-r {} \; \)
}

# Set open permissions (rw for everyone)
# Preserves execute bits only where they already exist
# Usage: perm-open <path>
unalias perm-open 2>/dev/null
function perm-open() {
    sudo find "$1" -type f \
        \( -perm /111 -exec chmod a+rw,u+X,g+X {} \; \) \
        -o \
        \( ! -perm /111 -exec chmod a+rw {} \; \)
}

# Set ownership to current user and restricted permissions
# Usage: perm-restricted-me <path>
function perm-restricted-me() {
    sudo chown -R $USER:$USER $1 && sudo chmod -R 775 $1
}

# GROUP AND USER INFORMATION
# ------------------------

function group-list() {
    local user="${1:-}"
    local header="%-8s ${WHITE}%-30s${RESET} %s\n"
    
    printf "$header" "GID" "GROUP" "MEMBERS"
    
    if [[ -z "$user" || "$user" == "all" ]]; then
        _list_all_groups
    else
        [[ "$user" == "me" ]] && user=$(whoami)
        _list_user_groups "$user"
    fi
}

function _list_all_groups() {
    getent group | sort -n -k3 -t: | while IFS=: read -r group_name x gid members; do
        local member_list=$(_format_member_list "$members" "true")
        printf "%-8s ${WHITE}%-30s${RESET} %s\n" "$gid" "$group_name" "$member_list"
    done
}

function _list_user_groups() {
    local user=$1
    groups "$user" | tr ' ' '\n' | sort -u | while read -r group; do
        getent group "$group" | while IFS=: read -r group_name x gid members; do
            local member_list=$(_format_member_list "$members" "true" "$user")
            printf "%-8s ${WHITE}%-30s${RESET} %s\n" "$gid" "$group_name" "$member_list"
        done
    done
}

function _format_member_list() {
    local members=$1
    local show_uid=$2
    local highlight_user=$3
    local result=""
    
    for member in ${(s:,:)members}; do
        [[ -z "$member" ]] && continue
        local uid=$(_get_user_uid "$member")
        local member_fmt="$member($uid)"
        
        if [[ -n "$highlight_user" && "$member" == "$highlight_user" ]]; then
            member_fmt="${GOLD}$member_fmt${RESET}"
        fi
        
        result="${result:+$result,}$member_fmt"
    done
    
    echo "$result"
}

# USER INFORMATION
# --------------

function user-list() {
    local current_user=$(whoami)
    printf "%-8s %-28s %s\n" "UID" "USER" "GROUPS"
    
    getent passwd | sort -n -t: -k3 | while IFS=: read -r username x uid gid rest; do
        _format_user_entry "$username" "$uid" "$current_user"
    done
}

function _format_user_entry() {
    local username=$1
    local uid=$2
    local current_user=$3
    
    # Skip if can't get primary group
    primary_info=$(id -ng "$username" 2>/dev/null) || return
    
    local primary_gid=$(id -g "$username" 2>/dev/null)
    local name_color="${username}" # default no color
    [[ "$username" == "$current_user" ]] && name_color="${GOLD}${username}${RESET}" || name_color="${WHITE}${username}${RESET}"
    
    local groups_list
    groups_list=$(_format_user_groups "$username" "$primary_info" "$primary_gid")
    [[ -z "$groups_list" ]] && return
    
    printf "%-8s %-28b %b\n" "$uid" "$name_color" "$groups_list"
}

function _format_user_groups() {
    local username=$1
    local primary_info=$2
    local primary_gid=$3
    
    local supplementary
    supplementary=$(_get_supplementary_groups "$username" "$primary_info")
    printf "%s%s%s%s" "${GREEN}${primary_info}(${primary_gid})${RESET}" "${supplementary:+, }" "$supplementary"
}

function _get_supplementary_groups() {
    local username=$1
    local primary_info=$2
    
    id -nG "$username" 2>/dev/null | tr ' ' '\n' | grep -v "^$primary_info\$" | while read -r group; do
        local gid=$(getent group "$group" | cut -d: -f3)
        [[ -n "$gid" ]] && printf "%s(%s)" "$group" "$gid"
    done | paste -sd ", " -
}

# SERVICE MANAGEMENT
# ----------------

# Check if a systemd service is currently running
# Usage: service-is-running <service-name>
# Returns: "<service> is running" or "<service> is not running"
function service-is-running() {
    local service=$1
    if [[ -z $service ]]; then
        echo "Usage: service-is-running <service>"
        return 1
    fi
    if [[ $(systemctl is-active $service) == "active" ]]; then
        echo "$service is running"
    else
        echo "$service is not running"
    fi
}

# List all services enabled on system startup
# Usage: service-list-on-startup
# Output: SERVICE NAME | STATUS
function service-list-on-startup() {
    local WHITE="\033[1;37m"
    local RESET="\033[0m"
    printf "${WHITE}%-40s %s${RESET}\n" "SERVICE" "STATUS"
    systemctl list-unit-files --type=service --state=enabled \
        | grep -v "^$\|listed$" \
        | sed 's/\.service[[:space:]]*/ /' \
        | awk '{printf "%-40s %s\n", $1, $2}' \
        | sort
}