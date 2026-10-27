#!/usr/bin/env bash
# Разворачивает чистый мак одной командой:
#
#   curl -fsSL https://raw.githubusercontent.com/n3iton/nixos/main/bootstrap.sh | bash -s -- macbook-air
#
# Если Determinate Nix не скачивается напрямую, передай прокси только для него:
#
#   curl -fsSL https://raw.githubusercontent.com/n3iton/nixos/main/bootstrap.sh | NIX_INSTALLER_PROXY=http://host:port bash -s -- macbook-air
#
# Аргумент — имя из darwinConfigurations во flake.nix.
# Скрипт идемпотентный: повторный запуск просто подтянет изменения и сделает switch.
set -euo pipefail

HOST="${1:?usage: bootstrap.sh <darwin-host>  (например macbook-air)}"

NIXOS_REPO="${NIXOS_REPO:-https://github.com/n3iton/nixos.git}"
NIXOS_DIR="${NIXOS_DIR:-$HOME/nixos}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/n3iton/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
STOW_PACKAGES="${STOW_PACKAGES:-tmux fish starship git ssh}"
DARWIN_REF="github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Этот скрипт только для macOS" >&2
  exit 1
fi
if [[ $EUID -eq 0 ]]; then
  echo "Запускай от своего пользователя, не через sudo" >&2
  exit 1
fi

# Прокси используется только для скачивания Determinate Nix и задаётся явно; brew, git, darwin-rebuild и всё остальное идут напрямую.
NIX_INSTALLER_PROXY="${NIX_INSTALLER_PROXY:-}"
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY

# Один раз спрашиваем пароль и держим sudo живым до конца скрипта
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &

# 1. Homebrew (заодно ставит Xcode Command Line Tools, а значит и git).
#    nix-darwin управляет пакетами brew, но сам brew не устанавливает.
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  log "Устанавливаю Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Determinate Nix
if [[ ! -x /nix/var/nix/profiles/default/bin/nix ]]; then
  # https_proxy подхватывают curl в скрипте-инсталляторе и сам инсталлятор
  # (он пробрасывает его через sudo); задаём только для этих двух команд
  DET_ENV=(env)
  if [[ -n "$NIX_INSTALLER_PROXY" ]]; then
    DET_ENV+=("https_proxy=$NIX_INSTALLER_PROXY" "NIX_INSTALLER_PROXY=$NIX_INSTALLER_PROXY")
    log "Устанавливаю Determinate Nix через прокси $NIX_INSTALLER_PROXY"
  else
    log "Устанавливаю Determinate Nix"
  fi
  "${DET_ENV[@]}" curl -fsSL https://install.determinate.systems/nix |
    "${DET_ENV[@]}" sh -s -- install --no-confirm
fi
# shellcheck disable=SC1091
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
NIX=/nix/var/nix/profiles/default/bin/nix

# 3. Репозитории
clone_or_pull() {
  local repo="$1" dir="$2"
  if [[ -d "$dir/.git" ]]; then
    log "Обновляю $dir"
    git -C "$dir" pull --ff-only || echo "Не удалось сделать pull в $dir, продолжаю с текущим состоянием"
  else
    log "Клонирую $repo в $dir"
    git clone "$repo" "$dir"
  fi
}
clone_or_pull "$NIXOS_REPO" "$NIXOS_DIR"
clone_or_pull "$DOTFILES_REPO" "$DOTFILES_DIR"

# 4. nix-darwin отказывается перезаписывать системные файлы,
#    поэтому при первом запуске отодвигаем их в *.before-nix-darwin
for f in /etc/bashrc /etc/zshrc /etc/zshenv /etc/zprofile /etc/shells; do
  if [[ -f "$f" && ! -L "$f" ]]; then
    sudo mv "$f" "$f.before-nix-darwin"
  fi
done

# 5. Применяем flake
log "darwin-rebuild switch --flake $NIXOS_DIR#$HOST"
if [[ -x /run/current-system/sw/bin/darwin-rebuild ]]; then
  sudo /run/current-system/sw/bin/darwin-rebuild switch --flake "$NIXOS_DIR#$HOST"
else
  sudo "$NIX" run "$DARWIN_REF" -- switch --flake "$NIXOS_DIR#$HOST"
fi

# 6. Dotfiles через stow (stow ставится brew'ом из flake).
#    Каталоги, куда пишут сами программы, создаём заранее: иначе stow свернёт их в ссылку
#    на dotfiles, и туда попадут, например, новые ssh-ключи или локальные конфиги.
log "stow: $STOW_PACKAGES"
mkdir -p "$HOME/.config/git"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
# stow не перезаписывает обычные файлы, поэтому то, что лежало до него, отодвигаем
# в *.before-stow. Файлы, которые уже ведут в dotfiles через свёрнутый каталог, не трогаем.
DOTFILES_REAL="$(cd "$DOTFILES_DIR" && pwd -P)"
for pkg in $STOW_PACKAGES; do
  while IFS= read -r rel; do
    target="$HOME/$rel"
    [[ -e "$target" && ! -L "$target" ]] || continue
    [[ "$(cd "$(dirname "$target")" && pwd -P)/" == "$DOTFILES_REAL"/* ]] && continue
    log "Отодвигаю $target -> $target.before-stow"
    mv "$target" "$target.before-stow"
  done < <(cd "$DOTFILES_DIR/$pkg" && find . -type f ! -name .DS_Store | sed 's#^\./##')
done
# shellcheck disable=SC2086
/opt/homebrew/bin/stow --dir "$DOTFILES_DIR" --target "$HOME" --restow $STOW_PACKAGES

# 7. VS Code: в dotfiles лежит линуксовый путь (.config/Code/User), а на маке
#    настройки в ~/Library/Application Support/Code/User — стоуим сам каталог User
VSCODE_USER="$HOME/Library/Application Support/Code/User"
if [[ -d "$DOTFILES_DIR/vscode/.config/Code/User" ]]; then
  log "VS Code: настройки и расширения"
  mkdir -p "$VSCODE_USER"
  # stow не перезаписывает обычные файлы, поэтому отодвигаем то, что создал VS Code
  if [[ -f "$VSCODE_USER/settings.json" && ! -L "$VSCODE_USER/settings.json" ]]; then
    mv "$VSCODE_USER/settings.json" "$VSCODE_USER/settings.json.bak"
  fi
  /opt/homebrew/bin/stow --dir "$DOTFILES_DIR/vscode/.config/Code" --target "$VSCODE_USER" --restow User

  if [[ -x /opt/homebrew/bin/code && -f "$DOTFILES_DIR/vscode-extensions.txt" ]]; then
    # || [[ -n ]] — чтобы не потерять последнюю строку без перевода строки
    while read -r ext || [[ -n "$ext" ]]; do
      [[ -n "$ext" ]] && /opt/homebrew/bin/code --install-extension "$ext" --force >/dev/null
    done <"$DOTFILES_DIR/vscode-extensions.txt"
  fi
fi

# 8. fish как login shell
FISH=/run/current-system/sw/bin/fish
if [[ "$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')" != "$FISH" ]]; then
  log "Делаю fish оболочкой по умолчанию"
  sudo chsh -s "$FISH" "$USER"
fi

# 9. Пароль сразу после сна и заставки. Через nix-darwin это не задать: ключ askForPassword
#    из com.apple.screensaver macOS больше не читает, а sysadminctl требует пароль пользователя.
#    Пароль читаем с терминала: stdin у скрипта — это сам скрипт (curl | bash).
if ! sysadminctl -screenLock status 2>&1 | grep -q 'screenLock delay is immediate'; then
  log "Включаю пароль сразу после сна (sysadminctl спросит пароль пользователя)"
  if ! sysadminctl -screenLock immediate -password - </dev/tty; then
    echo "Не удалось включить, позже вручную: sysadminctl -screenLock immediate -password -" >&2
  fi
fi

log "Готово. Дальше обновляться так: sudo darwin-rebuild switch --flake $NIXOS_DIR#$HOST"
