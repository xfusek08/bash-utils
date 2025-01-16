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

# Display group information with GIDs and members
# Usage: show-groups [username|me]
# Without args: shows all groups
# With username: shows groups for specific user
# With 'me': shows groups for current user
function group-list() {
    local user
    local WHITE="\033[1;37m"
    local GOLD="\033[1;33m"
    local RESET="\033[0m"

    if [[ $# -eq 0 ]]; then
        printf "%-8s ${WHITE}%-30s${RESET} %s\n" "GID" "GROUP" "MEMBERS"
        getent group | sort -n -k3 -t: | awk -F: -v white="$WHITE" -v gold="$GOLD" -v reset="$RESET" \
            'function get_uid(user) {
                cmd = "id -u " user " 2>/dev/null"
                cmd | getline uid
                close(cmd)
                return uid
            }
            {
                split($4, members, ",");
                memberlist="";
                for (i=1; i<=length(members); i++) {
                    if (members[i] != "") {
                        uid = get_uid(members[i]);
                        if (memberlist == "")
                            memberlist = members[i] "(" uid ")";
                        else
                            memberlist = memberlist "," members[i] "(" uid ")";
                    }
                }
                printf "%-8s %s%-30s%s %s\n", $3, white, $1, reset, memberlist;
            }'
    else
        if [[ "$1" == "me" ]]; then
            user=$(whoami)
        else
            user=$1
        fi
        printf "%-8s ${WHITE}%-30s${RESET} %s\n" "GID" "GROUP" "MEMBERS"
        groups $user | tr ' ' '\n' | sort -u | while read group; do
            getent group $group
        done | sort -n -k3 -t: | awk -F: -v user="$user" -v white="$WHITE" -v gold="$GOLD" -v reset="$RESET" \
            'function get_uid(user) {
                cmd = "id -u " user " 2>/dev/null"
                cmd | getline uid
                close(cmd)
                return uid
            }
            {
                split($4, members, ",");
                memberlist="";
                # Add group owner to members if its their primary group
                if ($1 == user) {
                    uid = get_uid(user);
                    memberlist = gold user "(" uid ")" reset;
                }
                for (i=1; i<=length(members); i++) {
                    if (members[i] != "") {
                        uid = get_uid(members[i]);
                        if (members[i] == user)
                            memberlist = memberlist (memberlist=="" ? "" : ",") gold members[i] "(" uid ")" reset;
                        else
                            memberlist = memberlist (memberlist=="" ? "" : ",") members[i] "(" uid ")";
                    }
                }
                printf "%-8s %s%-30s%s %s\n", $3, white, $1, reset, memberlist;
            }'
    fi
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

# USER INFORMATION
# --------------

# List all system users with their UIDs and group memberships
# Usage: user-list
# Output: UID | USERNAME | GROUPS(GID)
# Current user is highlighted in gold
# Primary group is highlighted in green
function user-list() {
    local WHITE="\033[1;37m"
    local GOLD="\033[1;33m"
    local GREEN="\033[1;32m"
    local RESET="\033[0m"
    local current_user=$(whoami)

    printf "%-8s ${WHITE}%-20s${RESET} %s\n" "UID" "USER" "GROUPS"
    getent passwd | sort -n -t: -k3 | while IFS=: read -r username x uid gid rest; do
        # Get primary group info
        if ! primary_info=$(id -ng "$username" 2>/dev/null); then
            continue
        fi
        primary_gid=$(id -g "$username" 2>/dev/null)
        
        # Get supplementary groups, excluding primary
        supplementary=$(id -nG "$username" 2>/dev/null | tr ' ' '\n' | grep -v "^$primary_info\$" | while read -r group; do
            gid=$(getent group "$group" | cut -d: -f3)
            [[ -n "$gid" ]] && printf "%s(%s)" "$group" "$gid"
        done | paste -sd " " -)

        # Format groups list with proper color interpretation - primary group in cyan
        groups_list=$(printf "${GREEN}%s(%s)${RESET}" "$primary_info" "$primary_gid")
        [[ -n "$supplementary" ]] && groups_list+=" $supplementary"
        
        if [[ -n "$groups_list" ]]; then
            if [[ "$username" == "$current_user" ]]; then
                printf "%-8s ${GOLD}%-20s${RESET} %s\n" "$uid" "$username" "$groups_list"
            else
                printf "%-8s ${WHITE}%-20s${RESET} %s\n" "$uid" "$username" "$groups_list"
            fi
        fi
    done
}