# Color definitions
WHITE=$'\033[1;37m'
GREEN=$'\033[1;32m'
CYAN=$'\033[1;36m'
RESET=$'\033[0m'

# List all listening ports and their associated programs
# Usage: listening-servers
function listening-servers() {
    printf "${WHITE}%-20s %-8s %-8s %s${RESET}\n" "PROGRAM" "PID" "PORT" "PROTOCOL"

    # Collect all listening ports using lsof
    sudo lsof -i -P -n | grep LISTEN |
        awk '{
            split($9, addr, ":")
            port = addr[length(addr)]
            printf "%-20s %-8s %-8s %s\n", $1, $2, port, $8
        }' |
        sort -k3 -n |
        while read -r prog pid port proto; do
            printf "${CYAN}%-20s${RESET} ${GREEN}%-8s${RESET} %-8s %s\n" \
                "$prog" "$pid" "$port" "$proto"
        done
}

# Alias for easier access
alias listening='listening-servers'
