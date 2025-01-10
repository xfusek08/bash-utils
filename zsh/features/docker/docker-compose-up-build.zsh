
function dcu() {
    local project_name=$(docker compose config --format json | jq -r '.name')
    
    echo "Cleaning up docker resources for project: ${project_name}"
    
    # Stop and remove containers
    docker compose down --remove-orphans >/dev/null 2>&1
    
    # Force remove any related containers
    docker ps -a | grep "${project_name}" | awk '{print $1}' | xargs -r docker rm -f >/dev/null 2>&1
    
    # Force remove any related networks
    docker network ls | grep "${project_name}" | awk '{print $1}' | xargs -r docker network rm >/dev/null 2>&1
    
    # Prune unused networks
    docker network prune -f >/dev/null 2>&1
    
    if [ -z "$1" ]; then
        docker compose up --build
    else
        docker compose --profile "$1" up --build
    fi
}
