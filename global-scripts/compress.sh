#!/bin/bash

# --- НАСТРОЙКИ ---
TARGET_SIZE_MB=385       # Целевой размер (чуть меньше 399.99 для надежности)
AUDIO_BITRATE_K=48       # Минимум для звука (48k Mono), остальное - видео
PRESET="slower"          # Баланс для мощного ноутбука (быстрее veryslow, лучше slow)

# Проверка аргументов
if [ -z "$1" ]; then
    echo "Использование: $0 <путь_к_файлу>"
    exit 1
fi

INPUT_FILE="$1"
FILENAME=$(basename -- "$INPUT_FILE")
FILENAME_NO_EXT="${FILENAME%.*}"
OUTPUT_FILE="${FILENAME_NO_EXT}_399mb.mp4"
LOG_PREFIX="ffmpeg2pass_$(date +%s)" # Уникальное имя лога, чтобы не конфликтовать

# Проверка зависимостей
if ! command -v ffmpeg &> /dev/null || ! command -v ffprobe &> /dev/null; then
    echo "Ошибка: Установи ffmpeg (sudo pacman -S ffmpeg)"
    exit 1
fi

echo ">>> Анализ файла: $FILENAME"

# Получаем длительность в секундах
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")

if [ -z "$DURATION" ]; then
    echo "Ошибка: Не удалось узнать длительность видео."
    exit 1
fi

# Расчет битрейта видео
# Формула: (Размер_MB * 8192 кбит) / сек - Аудио_битрейт
VIDEO_BITRATE_K=$(awk -v size="$TARGET_SIZE_MB" -v dur="$DURATION" -v audio="$AUDIO_BITRATE_K" 'BEGIN { print int( (size * 8192 / dur) - audio ) }')

# Защита от слишком коротких видео или ошибок расчета
if [ "$VIDEO_BITRATE_K" -le 100 ]; then
    echo "Внимание! Расчетный битрейт слишком мал или видео слишком длинное для такого размера."
    echo "Попробуем минимальный разумный битрейт, но размер может превысить лимит."
    VIDEO_BITRATE_K=500
fi

echo "------------------------------------------------"
echo " Длительность:  $DURATION сек"
echo " Видео битрейт: ${VIDEO_BITRATE_K}k (максимальное качество)"
echo " Аудио битрейт: ${AUDIO_BITRATE_K}k (Mono, экономия места)"
echo " Пресет:        $PRESET"
echo "------------------------------------------------"

echo ">>> Проход 1 из 2 (Анализ)..."
# Первый проход: без звука, быстрый анализ
ffmpeg -y -i "$INPUT_FILE" \
    -c:v libx264 -preset "$PRESET" -b:v "${VIDEO_BITRATE_K}k" \
    -pass 1 -passlogfile "$LOG_PREFIX" \
    -an -f null /dev/null

if [ $? -ne 0 ]; then
    echo "Ошибка на первом проходе!"
    rm -f "${LOG_PREFIX}-0.log" "${LOG_PREFIX}-0.log.mbtree"
    exit 1
fi

echo ">>> Проход 2 из 2 (Кодирование)..."
# Второй проход: финальное сжатие, звук в AAC Mono
ffmpeg -y -i "$INPUT_FILE" \
    -c:v libx264 -preset "$PRESET" -b:v "${VIDEO_BITRATE_K}k" \
    -pass 2 -passlogfile "$LOG_PREFIX" \
    -c:a aac -b:a "${AUDIO_BITRATE_K}k" -ac 1 \
    "$OUTPUT_FILE"

# Уборка мусора
rm -f "${LOG_PREFIX}-0.log" "${LOG_PREFIX}-0.log.mbtree"

echo ">>> Готово!"
echo "Файл: $OUTPUT_FILE"
du -h "$OUTPUT_FILE"
