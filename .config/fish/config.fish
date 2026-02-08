source /usr/share/cachyos-fish-config/cachyos-config.fish

if type -q eza
    # Просто ls, но с иконками и папки сверху
    alias ls "eza --icons --group-directories-first"

    # Список с деталями, git-статусом и заголовками
    alias ll "eza -l -g --icons --git --group-directories-first --time-style long-iso"

    # Показать всё (включая скрытые файлы)
    alias la "eza -l -a -g --icons --git --group-directories-first"

    # Дерево файлов (удобно для просмотра структуры проекта)
    alias lt "eza --tree --level=2 --icons"
end

if status is-interactive
    # Git
    abbr --add gs "git status"
    abbr --add ga "git add ."
    abbr --add gc "git commit -m"
    abbr --add gp "git push"
    # System
    abbr --add pac "sudo pacman -S"
end

alias myip="curl ifconfig.me"
alias cls="clear"
alias cat="bat"
alias d="docker"
alias d-c="docker-compose"
alias lg="lazygit"
alias ld="lazydocker"

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
   # smth smth
end
export PATH="$HOME/.local/bin:$PATH"

# pnpm
set -gx PNPM_HOME "/home/skippia/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Принудительно используем Block (квадрат) во всех режимах
set -g fish_cursor_default block
set -g fish_cursor_insert block
set -g fish_cursor_visual block
set -g fish_cursor_replace_one block

set -x MOZ_ENABLE_WAYLAND 1

starship init fish | source
eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
