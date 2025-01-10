
require_once "$ZSH_SCRIPTING_DIRECTORY/features/docker/docker-compose-down.zsh"

dcu() {
    dcd
    if [ -z "$1" ]; then
        docker compose up --build
    else
        docker compose --profile "$1" up --build
    fi
}
