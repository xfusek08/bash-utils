
function connect-to-docker() {
    local container_id=$1
    docker exec -it $container_id /bin/bash
}
