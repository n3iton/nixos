{ ... }:

{
  imports = [ ../../modules/darwin/common.nix ];

  # Пакеты из общего списка, которые не нужны на этом маке
  my.homebrew.excludeCasks = [
    "steam"
    "google-chrome"
    "claude-code"
    "lm-studio"
    "libreoffice"
    "simplex"
    "element"
    "lulu"
  ];

  my.homebrew.excludeBrews = [ ];

  home-manager.users.nikita = {
    imports = [ ../../home/common.nix ];
  };
}
