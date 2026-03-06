{ pkgs, ... }:

{
  nix.enable = false;

  users.users.nikita = {
    home = "/Users/nikita";
  };

  environment.systemPackages = with pkgs; [
    neovim
  ];

  system.stateVersion = 5;
}
