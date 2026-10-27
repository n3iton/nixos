{ ... }:

{
  imports = [ ../../modules/darwin/common.nix ];

  # hostName совпадает с именем во flake, поэтому darwin-rebuild switch работает без #host
  networking.hostName = "macbook-air";
  networking.computerName = "Nikita’s MacBook Air";

  # Трекпад: «естественная» прокрутка, тогда свайп влево ведёт на рабочий стол справа
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = true;

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
