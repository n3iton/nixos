{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.homebrew;

  casks = [
    "loop-messenger"
    "docker-desktop"
    "firefox"
    "kontur-talk"
    "kde-connect"
    "happ"
    # Пакеты из сторонних tap'ов пишем полным именем: тогда nix-darwin помечает их
    # trusted (Homebrew 7 без этого их не грузит), а brew bundle сам ставит нужный tap
    "throneproj/tap/throne"
    "visual-studio-code"
    "zoom"
    "monitorcontrol"
    "keepassxc"
    "obsidian"
    "steam"
    "amneziavpn"
    "google-chrome"
    "claude-code"
    "claude"
    "puremac"
    "lm-studio"
    "libreoffice"
    "telegram-desktop"
    "simplex"
    "yubico-authenticator"
    "element"
    "freelens"
    "lulu"
    "android-platform-tools"
    "localsend"
  ];

  brews = [
    "kubebuilder"
    "go-task"
    "werf"
    "yq"
    "trivy"
    "pre-commit"
    "syncthing"
    "starship"
    "nixfmt"
    "go"
    "tmux"
    "neovim"
    "tealdeer"
    "tree"
    "dive"
    "stow"
    "crane"
    "sing-box"
    "direnv"
    "xiaomiku01/tap/tetherkit" # полное имя — см. комментарий у casks
    "kind"
  ];
in
{
  # Общая конфигурация для всех маков.
  # Хост может исключить часть пакетов через my.homebrew.exclude{Casks,Brews}.
  options.my.homebrew = {
    excludeCasks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Casks из общего списка, которые не нужно ставить на этот хост.";
    };

    excludeBrews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Brews из общего списка, которые не нужно ставить на этот хост.";
    };
  };

  config = {
    # Опечатка в исключениях молча ничего бы не исключила — ловим её на сборке
    assertions = [
      {
        assertion = lib.subtractLists casks cfg.excludeCasks == [ ];
        message = "my.homebrew.excludeCasks: нет в общем списке: ${toString (lib.subtractLists casks cfg.excludeCasks)}";
      }
      {
        assertion = lib.subtractLists brews cfg.excludeBrews == [ ];
        message = "my.homebrew.excludeBrews: нет в общем списке: ${toString (lib.subtractLists brews cfg.excludeBrews)}";
      }
    ];

    nix.enable = false;

    users.users.nikita = {
      home = "/Users/nikita";
    };

    system.primaryUser = "nikita";

    programs.fish.enable = true;

    environment.shells = [ pkgs.fish ];

    # Rosetta 2 нужна Intel-приложениям, без неё brew bundle
    # на таких casks падает. extraActivation выполняется от root раньше шага homebrew.
    system.activationScripts.extraActivation.text = ''
      if ! /usr/bin/arch -x86_64 /usr/bin/true 2>/dev/null; then
        echo "installing Rosetta 2..." >&2
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
      fi
    '';

    homebrew = {
      enable = true;

      onActivation = {
        autoUpdate = true;
        upgrade = false;
      };

      casks = lib.subtractLists cfg.excludeCasks casks;

      brews = lib.subtractLists cfg.excludeBrews brews;
    };

    system.stateVersion = 5;
  };
}
