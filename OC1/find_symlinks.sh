#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Использование: $0 <целевой_файл>"
    exit 1
fi

TARGET=$(readlink -f "$1")
if [ ! -e "$TARGET" ]; then
    echo "Ошибка: Файл '$1' не существует"
    exit 1
fi

echo "Поиск символьных ссылок на: $TARGET"
echo "----------------------------------"

# Метод 1: Используя find и readlink
echo -e "\nМетод 1 (find + readlink):"
find / -type l -exec sh -c '
    for link; do
        if [ "$(readlink -f "$link")" = "'"$TARGET"'" ]; then
            echo "$link"
        fi
    done
' sh {} + 2>/dev/null | sort | uniq

# Метод 2: Используя ls и grep
echo -e "\nМетод 2 (ls + grep):"
ls -lR / 2>/dev/null | awk -v target="$TARGET" '
    /^[^d].* -> / {
        split($0, parts, " -> ");
        if (parts[2] == target) {
            gsub(/:$/, "", parts[1]);
            print parts[1]
        }
    }
' | sort | uniq

echo -e "\nПоиск завершен"
