require_once "_docker_completions.zsh"

docker-print-image-layers() {
    if [ -z "$1" ]; then
        echo "Usage: print_image_layers <image_name_or_id>"
        return 1
    fi

    local image_name="$1"

    # Check if the image exists
    if ! docker image inspect "$image_name" >/dev/null 2>&1; then
        echo "Error: Image '$image_name' not found."
        return 1
    fi

    # Print the layers of the image
    echo "Layers of image: $image_name"
    docker history --no-trunc "$image_name" | awk '{printf "%s %s %s\n", $5, $6, $7}'
}

compdef _docker_image_names_completion docker-print-image-layers
