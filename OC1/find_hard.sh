#!/bin/bash

[ -z "$1" ] && echo "Usage: $0 <target_file>" && exit 1

target="$1"
[ ! -e "$target" ] && echo "Error: File '$target' not found" && exit 1

# Получаем точные данные файла
inode=$(stat -c "%i" "$target")
device_major_minor=$(stat -c "%d" "$target")
device_name=$(df "$target" | awk 'NR==2 {print $1}')

echo "Searching for hard links to: $target"
echo "Inode: $inode, Device: $device_name"
echo "----------------------------------------"

# Метод 1: Через debugfs (самый надежный)
if command -v debugfs &>/dev/null; then
    echo "Method 1 (debugfs):"
    sudo debugfs -R "ncheck $inode" "$device_name" 2>/dev/null | \
    awk -v target="$target" '$2 != target {print $2}'
else
    echo "debugfs not installed, skipping method 1"
fi

# Метод 2: Через find (если разрешено)
echo "----------------------------------------"
echo "Method 2 (find):"
find / -xdev -inum "$inode" ! -path "$target" 2>/dev/null

# Метод 3: Альтернативный способ через ls
echo "----------------------------------------"
echo "Method 3 (ls/awk):"
ls -lRi / 2>/dev/null | \
awk -v inode="$inode" -v target="$target" '
    $1 == inode {
        for(i=9; i<=NF; i++) {
            if($i != target) {
                path = $i
                for(j=i+1; j<=NF; j++) {
                    path = path " " $j
                }
                print path
                next
            }
        }
    }'

echo "----------------------------------------"
echo "Search completed"
