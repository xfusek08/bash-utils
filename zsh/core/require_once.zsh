# Initialize an array to track sourced files
typeset -gA SOURCED_FILES
typeset -ga CAPTURED_FILES=()

REQUIRE_ONCE_CAPTURE=0

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
    if [[ -f "$abs_path" ]]; then
        source "$abs_path"
        SOURCED_FILES[$abs_path]=1
        if [[ $REQUIRE_ONCE_CAPTURE -eq 1 ]]; then
            CAPTURED_FILES+=("$abs_path")
        fi
    else
        echo "Error: File '$file' not found" >&2
        return 1 # Return error if the file doesn't exist
    fi
}

function require_once-start_capture() {
    REQUIRE_ONCE_CAPTURE=1
    CAPTURED_FILES=()
}

function require_once-end-capture() {
    REQUIRE_ONCE_CAPTURE=0
    printf "%s\n" "${CAPTURED_FILES[@]}"
}
