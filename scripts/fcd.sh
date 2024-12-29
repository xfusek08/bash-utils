_fzf_pretty() {
    # Parse options and arguments
    local all=false
    local opts
    opts=$(getopt -o ha --long help,all -n 'fcd' -- "$@")
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to parse options." >&2
        return 1
    fi
    
    eval set -- "$opts"
    
    while true; do
        case "$1" in
            -h|--help)
                echo -e "Usage: fcd [OPTIONS] [DIRECTORY]

Changes the current directory using fuzzy finder.

Options:
    -h        Show this help message
    -a        Include hidden directories in the search

Directory:
    The directory to search in. Default is the current directory.

Examples:
    fcd ~/projects/myproject
    fcd -a ~/projects/myproject"
                return 0
                ;;
            -a|--all)
                all=true
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "ERROR: Invalid option $1" >&2
                return 1
                ;;
        esac
    done

    # Get the directory to search in (now properly handling remaining argument after option parsing)
    local search_dir="."
    
    # Get the directory to search in from the first argument
    local dirName="$1"
    if [ "$dirName" == "" ]; then
        dirName=`pwd`
    fi
    
    echo "Searching in: $search_dir" >&2
    
    # Set bfs arguments based on all flag
    local bfs_args=""
    if [ "$all" != "true" ]; then
        bfs_args="-nohidden"
    fi

    local selectedString=$(bfs "$search_dir" $bfs_args | fzf --preview "batcat --color=always --style=numbers --line-range=:500 {}")
    local res=$(realpath "$selectedString")
    if [ ! -d "$res" ]; then
        res=$(dirname $res)
    fi
    echo "Navigation to:\n$res" >&2
    echo $res
}

alias fcd='cd "$(_fzf_pretty "$@")"'
