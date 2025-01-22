
_docker_container_names_completion() {
    local -a containers
    containers=("${(@f)$(docker ps --format '{{.Names}}' 2>/dev/null)}")
    _arguments "1:container:(${containers})"
}