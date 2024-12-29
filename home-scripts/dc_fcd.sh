#!/bin/bash

# Redirect all output and errors to a log file
log_file="${HOME}/fzdirmod_error.log"
[[ -f "${log_file}" ]] && rm "${log_file}"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "${log_file}"
}

function fzdirmod() {
    log "Executing fzdirmod function"
    
    # Get the directory name from argument or default to current directory
    local dir_name="${1:-$(pwd)}"
    
    # Validate and expand the directory path
    if [[ ! -d "${dir_name}" ]]; then
        log "Error: '${dir_name}' is not a valid directory"
        return 1
    fi
    
    dir_name=$(realpath "${dir_name}")
    if [[ $? -ne 0 ]]; then
        log "Error: Failed to resolve path '${dir_name}'"
        return 1
    fi
    
    log "Opening directory: ${dir_name}"

    # Create temporary script file
    local tmp_script=$(mktemp)
    
    # Write script content
    cat > "${tmp_script}" << EOF
#!/bin/zsh
source ~/.zshrc

function log() {
    echo "[\\$(date +'%Y-%m-%d %H:%M:%S')] \$*" >> "${log_file}"
}

log "Current directory: ${dir_name}"
selected_dir=\$(fcd -p "${dir_name}")

if [[ -n "\$selected_dir" ]]; then
    log "Selected directory: \$selected_dir"
    doublecmd --no-splash --client "\$selected_dir"
else
    log "No directory selected"
fi

exit 0
EOF

    # Make script executable
    chmod +x "${tmp_script}"
    
    log "Created temporary script: ${tmp_script}"
    
    log $(bat "${tmp_script}")

    # Execute through ghostty
    ghostty -e "zsh ${tmp_script}"

    # Clean up
    rm "${tmp_script}"
}

# Just call the function with the provided argument
fzdirmod "$1"
