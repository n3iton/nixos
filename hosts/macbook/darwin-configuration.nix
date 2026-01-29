{ pkgs, ... }:

{
  nix.enable = false;

  users.users.yourname = {
    home = "/Users/neiton";
  };

  environment.systemPackages = with pkgs; [
    neovim
  ];

  system.stateVersion = 5;
}
