#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <target_file>"
    exit 1
fi

TARGET=$(readlink -f "$1")
if [ ! -e "$TARGET" ]; then
    echo "Error: Target file does not exist"
    exit 1
fi

echo "Searching symlinks to: $TARGET"

# Способ 1: find + readlink
echo -e "\nMethod 1 (find + readlink):"
find / -type l -exec sh -c '
    for link; do
        if [ "$(readlink -f "$link")" = "'"$TARGET"'" ]; then
            echo "$link"
        fi
    done
' sh {} + 2>/dev/null

# Способ 2: ls + grep
echo -e "\nMethod 2 (ls + grep):"
ls -lR / 2>/dev/null | grep -E "-> ${TARGET//\//\\/}$" | awk -F': ' '{print $1}'
