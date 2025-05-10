#!/bin/bash

# Проверяем, что передано имя выходного файла
if [ -z "$1" ]; then
    echo "Usage: $0 <output_file1>"
    exit 1
fi

output_file="$1"

# Очищаем выходной файл
> "$output_file1"

# Функция для поиска и записи первого найденного файла определенного типа
find_and_write() {
    local path="$1"
    local pattern="$2"
    local prefix="$3"
    
    local found=$(ls -l "$path" 2>/dev/null | grep "$pattern" | head -1 | awk -v p="$prefix" '{print p$NF}')
    if [ -n "$found" ]; then
        echo "$found" >> "$output_file"
    fi
}

# Ищем примеры каждого типа файлов
find_and_write / '^-' '/'               # Обычный файл
find_and_write / '^d' '/'               # Директория
find_and_write /dev '^l' '/dev/'        # Символическая ссылка
find_and_write /dev '^b' '/dev/'        # Блочное устройство
find_and_write /dev '^c' '/dev/'        # Символьное устройство
find_and_write /run '^s' '/run/'        # Сокет
find_and_write /run/systemd '^p' '/run/systemd/' # Именованный канал (FIFO)

echo "Результаты сохранены в $output_file"
