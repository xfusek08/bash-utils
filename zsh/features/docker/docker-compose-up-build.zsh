require_once "_docker_compose_shared.zsh"

function dcu() {
    function _run_compose_up() {
        if [ -z "$1" ]; then
            docker compose up --build
        else
            docker compose --profile "$1" up --build
        fi
    }

    _docker_compose_check_file || return 1
    
    local compose_config="$(_docker_compose_get_config)"
    if [ $? -ne 0 ]; then
        echo "Docker compose configuration error detected, skipping cleanup"
        _run_compose_up "$1"
        return 1
    fi

    _docker_compose_down_all || return 1
    
    # Run docker compose up with or without profile
    _run_compose_up "$1"
}
