# Function to run cloc (Count Lines of Code) using Docker
# This allows using cloc without installing it locally

function loc() {
    # Check if Docker is available
    if ! command -v docker >/dev/null 2>&1; then
        echo "Error: Docker is not installed or not in PATH" >&2
        return 1
    fi
    
    # Set default arguments if none provided
    local args="${@:-.}"
    
    # Use alpine-based image with cloc installed
    echo "Running cloc in Docker container..."
    
    # Run cloc in Docker with current directory mounted
    docker run --rm \
        -v "$(pwd):/workdir:ro" \
        -w /workdir \
        aldanial/cloc:latest \
        $args
}

# Add alias for backward compatibility if someone is used to the 'cloc' command
alias cloc='loc'
