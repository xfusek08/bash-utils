
function pandoc() {
    docker run --rm -u $(id -u):$(id -g) -v "$(pwd)":/pandoc dalibo/pandocker:stable "$@"
}
