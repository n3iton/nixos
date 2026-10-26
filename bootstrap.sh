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
STOW_PACKAGES="${STOW_PACKAGES:-tmux fish starship}"
DARWIN_REF="github:nix-darwin/nix-darwin/nix-darwin-25.11#darwin-rebuild"

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
#    ~/.config создаём заранее, иначе stow превратит в симлинк весь каталог.
log "stow: $STOW_PACKAGES"
mkdir -p "$HOME/.config"
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

log "Готово. Дальше обновляться так: sudo darwin-rebuild switch --flake $NIXOS_DIR#$HOST"
