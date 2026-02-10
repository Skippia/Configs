#!/bin/sh

#!/bin/sh

# Путь к твоим хранилищам
BASE_PATH="/home/skippia/[KnowledgeStorages]/ObsidianStorage"

# --- НОВЫЙ БЛОК ---
# Принудительно удаляем старые "замки" на случай, если что-то упало
rm -f "${BASE_PATH}/Prog/.git/index.lock"
rm -f "${BASE_PATH}/Self/.git/index.lock"
# ------------------

# Запускаем цепочку команд с правильными путями
(cd "${BASE_PATH}/Prog" && git add -A && (git commit -m 'new' || true) && git push) && \
(cd "${BASE_PATH}/Self" && git add -A && (git commit -m 'new' || true) && git push)

# Проверяем код завершения и отправляем уведомление
if [ $? -eq 0 ]; then
    # Если все прошло без ошибок (код 0)
    notify-send "Obsidian Sync" "Синхронизация прошла успешно!" -i "dialog-information"
else
    # Если была ошибка
    notify-send "Obsidian Sync ОШИБКА" "Во время синхронизации произошла ошибка." -i "dialog-error"
fi
