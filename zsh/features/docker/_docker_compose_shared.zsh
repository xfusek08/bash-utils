function _docker_compose_check_file() {
    if [[ ! -f "docker-compose.yml" && ! -f "compose.yml" && ! -f "docker-compose.yaml" && ! -f "compose.yaml" ]]; then
        echo "Error: No docker-compose.yml or compose.yml found in current directory"
        return 1
    fi
    return 0
}

function _docker_compose_get_config() {
    local compose_config="$(docker compose config --format json 2>/dev/null)"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get docker compose config"
        return 1
    fi
    echo "${compose_config}"
}

function _docker_compose_down_all() {
    local quiet=$1
    
    _docker_compose_check_file || return 1
    
    local compose_config="$(_docker_compose_get_config)"
    if [ $? -ne 0 ]; then
        echo "Docker compose configuration error detected"
        return 1
    fi

    local project_name="$(echo "${compose_config}" | jq -r '.name')"
    local profiles="$(docker compose config --profiles 2>/dev/null)"
    
    [ "$quiet" != "quiet" ] && {
        echo "Project name: ${project_name}"
        echo "Available profiles: ${profiles}"
        
        if [[ -n "${project_name}" && "${project_name}" != "null" ]]; then
            echo "Cleaning up docker resources for project: ${project_name}"
        else
            echo "Cleaning up docker resources"
        fi
    }

    # Stop and remove containers for default profile
    docker compose down --remove-orphans >/dev/null 2>&1

    # Stop and remove containers for all detected profiles
    if [ -n "${profiles}" ]; then
        [ "$quiet" != "quiet" ] && echo "Cleaning up containers from all profiles..."
        echo "${profiles}" | tr ' ' '\n' | while read -r profile; do
            [ -n "${profile}" ] || continue
            [ "$quiet" != "quiet" ] && echo "Cleaning up profile: ${profile}"
            docker compose --profile "${profile}" down --remove-orphans >/dev/null 2>&1
        done
    fi
}
