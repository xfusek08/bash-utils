#!/bin/bash

fzdirmod() {
    dn="$1"
    if [ "$dn" == "" ]; then
        dn=`pwd`;
    fi

    PIPE=/tmp/fzfpipe
    if [[ -p $PIPE ]]; then
        rm $PIPE;
    fi;

    mkfifo $PIPE
    exec 3<>$PIPE

    echo "$dn" > /dev/tty

    command="\
        source ~/.bash_aliases; \
        exec 3<>$PIPE; \
        fcd \"$dn\" -p >&3; \
        exec 3>&-; \
    "

    command="bash -c '$command'"

    gnome-terminal.wrapper -geometry 1200x800 -e "$command"

    final_dir=`head -n1 <&3`

    # Echo final dir if it is not empty
    if [ "$final_dir" != "" ]; then
        echo "$final_dir"
    fi

    #close pipes
    exec 3>&-
    rm $PIPE
}

a=$(fzdirmod "$1")
if [ "$a" != "" ]; then
    doublecmd --no-splash --client "$a"
fi
