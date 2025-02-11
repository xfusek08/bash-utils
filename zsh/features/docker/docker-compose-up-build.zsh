function dcu() {
    # Check if docker-compose.yml exists
    if [[ ! -f "docker-compose.yml" && ! -f "compose.yml" ]]; then
        echo "Error: No docker-compose.yml or compose.yml found in current directory"
        return 1
    fi

    # Try to get project name, capture any errors
    local project_name="$(docker compose config --format json 2>/dev/null | jq -r '.name' 2>/dev/null)"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get project name from docker compose config"
        echo "Docker compose configuration error detected, skipping cleanup"
        # Just attempt to run docker compose up, which will show the actual error
        if [ -z "$1" ]; then
            docker compose up --build
        else
            docker compose --profile "$1" up --build
        fi
        return 1
    fi

    # Only proceed with cleanup if we have a valid project name
    if [[ -n "${project_name}" && "${project_name}" != "null" ]]; then
        echo "Cleaning up docker resources for project: ${project_name}"

        # Stop and remove containers for this project only
        docker compose down --remove-orphans >/dev/null 2>&1

        # Force remove any related containers
        docker ps -a | grep "${project_name}" | awk '{print $1}' | xargs -r docker rm -f >/dev/null 2>&1

        # Force remove any related networks
        docker network ls | grep "${project_name}" | awk '{print $1}' | xargs -r docker network rm >/dev/null 2>&1

        # Prune unused networks
        docker network prune -f >/dev/null 2>&1
    fi

    # Run docker compose up with or without profile
    if [ -z "$1" ]; then
        docker compose up --build
    else
        docker compose --profile "$1" up --build
    fi
}
