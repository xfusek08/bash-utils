
function docker-connect-to-container() {
    local container_id=$1
    docker exec -it $container_id /bin/sh
}

alias dcc=docker-connect-to-container
