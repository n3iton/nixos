{ ... }:

{
  imports = [ ../../modules/darwin/common.nix ];

  # hostName совпадает с именем во flake, поэтому darwin-rebuild switch работает без #host
  networking.hostName = "mac-mini";
  networking.computerName = "Nikita’s Mac mini";

  # Мышь, а не трекпад: колесо без «естественной» прокрутки
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  home-manager.users.nikita = {
    imports = [ ../../home/common.nix ];
  };
}
