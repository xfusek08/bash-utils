#!/bin/bash

# perform the breadth-first search
unalias find_bfs 2>/dev/null #remove potential alias
find_bfs() {
    fifo=$(mktemp -u)
    mkfifo "$fifo"
    
    cleanup() {
        echo "Cleaning up" >&2
        rm -f "$fifo"
        kill $(ps -s $$ -o pid=)
    }
    
    trap 'cleanup; exit' INT TERM EXIT  SIGPIPE
    
    # Start reader first to prevent deadlock
    (
        echo "Reading from FIFO" >&2
        exec cat <> "$fifo"
        echo "Done reading" >&2
    ) &
    reader_pid=$!
    
    (
        cleanup_inner() {
            echo "Cleaning up inner" >&2
            # kill child processes spawned by this process
            kill $(ps -s $$ -o pid=)
        }
        
        trap 'cleanup_inner; exit' INT TERM EXIT SIGPIPE
        
        depth=0
        while true; do
            echo "Depth: $depth" >&2
            count=$(find "$@" -mindepth "$depth" -maxdepth "$depth" | tee "$fifo" | wc -l)
            if [ "$count" -eq 0 ]; then
                break
            fi
            depth=$((depth + 1))
            # sleep 1
        done
        echo "Done" >&2
        cleanup_inner
    ) &
    writer_pid=$!
    
    echo "Waiting for writer to finish" >&2
    wait $writer_pid
    kill $reader_pid
    cleanup
}
