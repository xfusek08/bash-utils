require_once "_docker_completions.zsh"

function docker-connect-to-container() {
    local container_id=$1
    local init_command=$2
    local shell_cmd="/bin/sh"

    # Try to use bash if available in container
    if docker exec $container_id which bash >/dev/null 2>&1; then
        shell_cmd="/bin/bash"
    fi

    if [ -n "$init_command" ]; then
        docker exec -it $container_id $shell_cmd -c "$init_command && $shell_cmd"
    else
        docker exec -it $container_id $shell_cmd
    fi
}

alias dcc=docker-connect-to-container

compdef _docker_container_names_completion docker-connect-to-container
