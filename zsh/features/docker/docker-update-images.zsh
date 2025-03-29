#!/bin/bash

function docker-update-images() {
    local force_update=false
    local quiet_mode=false
    
    # Parse command line options
    while getopts "fq" opt; do
        case $opt in
            f) force_update=true ;;
            q) quiet_mode=true ;;
            *)
                echo "Usage: docker-update-images [-f] [-q]"
                echo "  -f: Force update even if image appears current"
                echo "  -q: Quiet mode - suppress progress messages"
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))
    
    # Get unique valid images
    local -a images
    images=($(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | sort -u))
    
    if [ ${#images[@]} -eq 0 ]; then
        [ "$quiet_mode" = false ] && echo "No Docker images found"
        return 0
    fi

    # Initialize counters
    local updated=0 already_latest=0 failed=0 total=${#images[@]}
    local current_digest new_digest pull_output

    [ "$quiet_mode" = false ] && echo "Processing $total Docker images..."
    
    for img in "${images[@]}"; do
        # Get current digest (if any)
        current_digest=$(docker image inspect --format '{{index .RepoDigests 0}}' "$img" 2>/dev/null)
        
        # Determine if we should check for updates
        local should_pull=false
        if [ "$force_update" = true ] || [ -z "$current_digest" ]; then
            should_pull=true
        fi

        # Pull image if needed
        if $should_pull; then
            [ "$quiet_mode" = false ] && echo "Pulling $img..."
            if docker pull -q "$img" >/dev/null 2>&1; then
                new_digest=$(docker image inspect --format '{{index .RepoDigests 0}}' "$img" 2>/dev/null)
                
                if [ -z "$current_digest" ]; then
                    # Newly acquired image
                    ((updated++))
                    [ "$quiet_mode" = false ] && echo "✓ Downloaded $img"
                elif [ "$current_digest" != "$new_digest" ]; then
                    ((updated++))
                    [ "$quiet_mode" = false ] && echo "✓ Updated $img"
                else
                    ((already_latest++))
                    [ "$quiet_mode" = false ] && echo "✓ Already latest $img"
                fi
            else
                ((failed++))
                [ "$quiet_mode" = false ] && echo "✗ Failed to update $img"
            fi
            continue
        fi

        # Regular update check
        [ "$quiet_mode" = false ] && echo "Checking $img..."
        if docker pull -q "$img" >/dev/null 2>&1; then
            new_digest=$(docker image inspect --format '{{index .RepoDigests 0}}' "$img" 2>/dev/null)
            
            if [ "$current_digest" != "$new_digest" ]; then
                ((updated++))
                [ "$quiet_mode" = false ] && echo "✓ Updated $img"
            else
                ((already_latest++))
                [ "$quiet_mode" = false ] && echo "✓ Already current $img"
            fi
        else
            ((failed++))
            [ "$quiet_mode" = false ] && echo "✗ Failed to check $img"
        fi
    done

    # Print summary
    echo
    echo "Docker images update report:"
    printf "  Updated:        %d\n" "$updated"
    printf "  Up-to-date:     %d\n" "$already_latest"
    printf "  Failed:         %d\n" "$failed"
    printf "  Total images:   %d\n" "$total"
}

alias dui=docker-update-images