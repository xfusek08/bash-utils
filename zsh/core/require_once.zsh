# Initialize an array to track sourced files
typeset -gA SOURCED_FILES
typeset -ga CAPTURED_FILES=()
typeset -ga IMPORT_STACK=()  # Added global import stack

REQUIRE_ONCE_CAPTURE=0

# Define a require_once function with relative path resolution using global stack
require_once() {
    local file="$1"
    
    # Resolve relative paths if IMPORT_STACK is not empty
    if [[ "$file" != /* ]] && [[ ${#IMPORT_STACK[@]} -gt 0 ]]; then
        file="${IMPORT_STACK[-1]}/$file"
    fi
    
    local abs_path="$(realpath "$file" 2>/dev/null || echo "$file")"
    
    # Check if the file has already been sourced
    if [[ -n "${SOURCED_FILES[$abs_path]}" ]]; then
        return 0 # Already sourced, skip
    fi
    
    if [[ -f "$abs_path" ]]; then
        # Push the directory of the file being sourced to IMPORT_STACK
        local dir
        dir=$(dirname "$abs_path")
        IMPORT_STACK+=( "$dir" )
        
        source "$abs_path"
        
        # Pop the directory after sourcing completes
        unset 'IMPORT_STACK[-1]'
        
        SOURCED_FILES[$abs_path]=1
        if [[ $REQUIRE_ONCE_CAPTURE -eq 1 ]]; then
            CAPTURED_FILES+=("$abs_path")
        fi
    else
        echo "Error: File '$file' not found" >&2
        return 1
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
