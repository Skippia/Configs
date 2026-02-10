#!/bin/bash

# Получаем информацию о сфокусированном окне от Niri
FOCUSED_WINDOW=$(niri msg -j windows | jq -r '.[] | select(.is_focused)')
PID=$(echo "$FOCUSED_WINDOW" | jq -r '.pid')

# Директория по умолчанию - домашняя папка
TARGET_DIR="$HOME"

if [ "$PID" != "null" ] && [ -n "$PID" ]; then
    # Пытаемся найти дочерний процесс (оболочку fish/bash) внутри терминала.
    # pgrep -P ищет детей процесса. -n берет самого нового (актуально, если запущен vim или ssh).
    # Если детей нет (редкий случай), берем сам PID окна.
    CHILD_PID=$(pgrep -P "$PID" -n)
    
    if [ -z "$CHILD_PID" ]; then
        CHECK_PID=$PID
    else
        CHECK_PID=$CHILD_PID
    fi

    # Читаем симлинк cwd из procfs
    if [ -e "/proc/$CHECK_PID/cwd" ]; then
        CWD=$(readlink "/proc/$CHECK_PID/cwd")
        # Проверяем, что это директория и она существует
        if [ -d "$CWD" ]; then
            TARGET_DIR="$CWD"
        fi
    fi
fi

# Запускаем Ghostty в найденной директории
ghostty --working-directory="$TARGET_DIR"
