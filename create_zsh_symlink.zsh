#!/bin/zsh
local from="${0:A:h}/zsh/.zshrc"
local to="$HOME/.zshrc"

# check if the file exists
if [ ! -f $from ]; then
    echo "FRom file $from does not exist"
    exit 1
fi

rm -f $to

echo "$to -> $from"

ln -s $from $to
