_docker_container_names_completion() {
    local -a containers
    containers=("${(@f)$(docker ps --format '{{.Names}}' 2>/dev/null)}")
    _arguments "1:container:(${containers})"
}

_docker_image_names_completion() {
    local -a images
    images=(${(f)"$(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -v '<none>:<none>')"})
    compadd "$@" -a images
}