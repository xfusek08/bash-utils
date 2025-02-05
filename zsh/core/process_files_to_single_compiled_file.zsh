#!/bin/zsh

require_once "$LIB_PATH/log.zsh"

# New filter functions for modular conditions
function filter_not_commented() {
    while IFS= read -r line; do
        [[ ! $line =~ ^[[:space:]]*# ]] && printf '%s\n' "$line"
    done
}

function filter_not_source() {
    while IFS= read -r line; do
        [[ $line != .* && $line != source* ]] && printf '%s\n' "$line"
    done
}

function filter_not_empty() {
    while IFS= read -r line; do
        [[ -n ${line//[[:space:]]/} ]] && printf '%s\n' "$line"
    done
}

# New filter to omit lines calling require_once
function filter_not_require_once() {
    while IFS= read -r line; do
        [[ $line != *require_once* ]] && printf '%s\n' "$line"
    done
}

process_files_to_single_compiled_file() {
    local line_name_list="$1"
    local output_file_name="$2"

    local total_source_lines=0
    local total_inlined_lines=0

    echo "" >"$output_file_name"

    # for each line in files
    while IFS= read -r file; do
        # if file is invalid log error and continue
        if [[ ! -f "$file" ]]; then
            log -e "File $file does not exist, skipping"
            continue
        fi

        local line_count=0
        local file_lines=0

        log -d "Processing file $file"
        while IFS= read -r line || [[ -n $line ]]; do
            ((file_lines++))
            # Use print -r instead of echo to preserve literal escape sequences.
            filtered_line=$(print -r -- "$line" | filter_not_commented | filter_not_empty | filter_not_require_once)
            if [[ -n "$filtered_line" ]]; then
                printf '%s\n' "$filtered_line" >>"$output_file_name"
                ((line_count++))
                log -d "🟢 Accepted: $filtered_line"
            else
                log -d "🔴 Rejected: $line"
            fi
        done <"$file"

        # Update total counters
        total_source_lines=$((total_source_lines + file_lines))
        total_inlined_lines=$((total_inlined_lines + line_count))

        log "$(printf "Inlined %4d lines from %s\n" "$line_count" "$file")"

    done <<<"$line_name_list"

    # Print final statistics
    log "\nFinal Statistics:"
    log "Total source lines: $total_source_lines"
    log "Total inlined lines: $total_inlined_lines"
    stripped_lines=$((total_source_lines - total_inlined_lines))
    stripped_percent=$(awk "BEGIN {printf \"%.1f\", ($stripped_lines / $total_source_lines) * 100}")
    log "Stripped lines: $stripped_lines ($stripped_percent%)"

}
