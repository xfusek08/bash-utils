# Initialize an array to track sourced files
typeset -gA SOURCED_FILES
typeset -ga CAPTURED_FILES=()
typeset -ga IMPORT_STACK=()  # Added global import stack

REQUIRE_ONCE_CAPTURE=0


# Add helper function to normalize IMPORT_STACK
normalize_stack() {
    local new_stack=()
    for item in "${IMPORT_STACK[@]}"; do
        [[ -n "$item" ]] && new_stack+=( "$item" )
    done
    IMPORT_STACK=("${new_stack[@]}")
}

# Add helper functions for stack management
push_stack() {
    [[ -z "$1" ]] && return
    IMPORT_STACK+=( "$1" )
    normalize_stack
}

pop_stack() {
    unset 'IMPORT_STACK[-1]'
    normalize_stack
}

top_stack() {
    echo "${IMPORT_STACK[-1]}"
}

# Define a require_once function with relative path resolution using global stack
require_once() {
    local file="$1"
    local file_path="$file"
    local extra_path="$2"
    local pushed=""
    
    # If a second parameter is provided, push it to the stack.
    if [[ -n "$extra_path" ]]; then
        push_stack "$extra_path"
        pushed=1
    fi
    
    local context_dir="$(top_stack)"
    
    # Simplified relative path resolution using context_dir
    if [[ "$file" != /* ]] && [[ -n "$context_dir" ]]; then
        file_path="${context_dir}/$file"
    fi
    
    local abs_path="$(realpath "$file_path" 2>/dev/null || echo "$file_path")"
    
    # Check if the file has already been sourced
    if [[ -n "${SOURCED_FILES[$abs_path]}" ]]; then
        [[ -n "$pushed" ]] && pop_stack
        return 0
    fi
    
    if [[ -f "$abs_path" ]]; then
        # Push the directory of the file being sourced to IMPORT_STACK
        local dir
        dir=$(dirname "$abs_path")
        
        push_stack "$dir"
        source "$abs_path"
        pop_stack
        
        [[ -n "$pushed" ]] && pop_stack
        
        SOURCED_FILES[$abs_path]=1
        if [[ $REQUIRE_ONCE_CAPTURE -eq 1 ]]; then
            CAPTURED_FILES+=("$abs_path")
        fi
    else
        [[ -n "$pushed" ]] && pop_stack
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
