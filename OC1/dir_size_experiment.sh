#!/bin/bash

# Создаём временный каталог для экспериментов
TEST_DIR="./test_dir_$(date +%s)"
mkdir -p "$TEST_DIR"
echo "Создан тестовый каталог: $TEST_DIR"

# Функция для отображения размера каталога
show_dir_size() {
    echo "Текущий размер каталога:"
    du -sh "$TEST_DIR"
    echo "Количество файлов:"
    find "$TEST_DIR" -type f | wc -l
    echo "Количество подкаталогов:"
    find "$TEST_DIR" -type d | wc -l
    echo "Inode каталога:"
    ls -id "$TEST_DIR"
}

# 1. Показываем начальный размер
echo -e "\n=== Начальное состояние ==="
show_dir_size

# 2. Создаём 1000 маленьких файлов
echo -e "\n=== Создаём 1000 файлов по 1Кб ==="
for i in {1..1000}; do
    dd if=/dev/zero of="$TEST_DIR/file_$i" bs=1K count=1 &>/dev/null
done
show_dir_size

# 3. Создаём 100 подкаталогов
echo -e "\n=== Создаём 100 подкаталогов ==="
for i in {1..100}; do
    mkdir -p "$TEST_DIR/subdir_$i"
done
show_dir_size

# 4. Создаём по 10 файлов в каждом подкаталоге
echo -e "\n=== Создаём по 10 файлов в каждом подкаталоге ==="
for dir in "$TEST_DIR"/subdir_*; do
    for i in {1..10}; do
        touch "$dir/subfile_$i"
    done
done
show_dir_size

# 5. Удаляем половину файлов
echo -e "\n=== Удаляем 500 файлов из корня ==="
find "$TEST_DIR" -maxdepth 1 -type f -name "file_*" | head -500 | xargs rm -f
show_dir_size

# 6. Удаляем все подкаталоги
echo -e "\n=== Удаляем все подкаталоги ==="
rm -rf "$TEST_DIR"/subdir_*
show_dir_size

# 7. Удаляем оставшиеся файлы
echo -e "\n=== Удаляем оставшиеся файлы ==="
rm -f "$TEST_DIR"/*
show_dir_size

# Удаляем тестовый каталог
read -p "Удалить тестовый каталог $TEST_DIR? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$TEST_DIR"
    echo "Каталог удалён"
else
    echo "Каталог сохранён: $TEST_DIR"
fi
