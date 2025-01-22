require_once "$ZSH_SCRIPTING_DIRECTORY/features/docker/_docker_completions.zsh"

function docker-connect-to-container() {
    local container_id=$1
    docker exec -it $container_id /bin/sh
}

alias dcc=docker-connect-to-container
compdef _docker_container_names_completion docker-connect-to-container
