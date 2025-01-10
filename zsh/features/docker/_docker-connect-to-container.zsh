
#compdef docker-connect-to-container

_docker_connect_to_container() {
    local -a containers
    containers=("${(@f)$(docker ps --format '{{.Names}}' 2>/dev/null)}")
    _arguments "1:container:(${containers})"
}

compdef _docker_connect_to_container docker-connect-to-container
