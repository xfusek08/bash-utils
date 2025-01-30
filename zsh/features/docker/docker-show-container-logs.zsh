require_once "$ZSH_SCRIPTING_DIRECTORY/features/docker/_docker_completions.zsh"

function docker-show-container-logs() {
    local container_id=$1
    docker logs -f $container_id 2>&1 | stdbuf -oL batcat --paging=always --italic-text=always --color=always --decorations=always --wrap=never --plain --language=log
}

alias dcl=docker-show-container-logs
compdef _docker_container_names_completion docker-show-container-logs