#!/bin/bash

# perform the breadth-first search
unalias find_bfs 2>/dev/null #remove potential alias
find_bfs() {
    exec 3>&1
    depth=0
    while [ true ]; do
        lines=$(find "$@" -mindepth "$depth" -maxdepth "$depth" | tee /dev/fd/3 | wc -l)
        if [ $lines -eq 0 ]; then
            break
        fi
        depth=$((depth+1))
    done
    exec 3>&-
}
