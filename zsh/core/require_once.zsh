# Initialize an array to track sourced files
typeset -gA SOURCED_FILES

# Define a require_once function
require_once() {
    local file="$1"

    # Resolve to an absolute path to avoid duplication due to relative paths
    local abs_path="$(realpath "$file" 2>/dev/null || echo "$file")"

    # Check if the file has already been sourced
    if [[ -n "${SOURCED_FILES[$abs_path]}" ]]; then
        return 0 # Already sourced, skip
    fi

    # Source the file and mark it as sourced
    if [[ -f "$file" ]]; then
        source "$file"
        SOURCED_FILES[$abs_path]=1
    else
        echo "Error: File '$file' not found" >&2
        return 1 # Return error if the file doesn't exist
    fi
}
