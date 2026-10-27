{ ... }:

{
  imports = [ ../../modules/darwin/common.nix ];

  # hostName совпадает с именем во flake, поэтому darwin-rebuild switch работает без #host
  networking.hostName = "macbook-air";
  networking.computerName = "Nikita’s MacBook Air";

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
