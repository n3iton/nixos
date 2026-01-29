{ pkgs, ... }:

{
  nix.package = pkgs.nix;

  users.users.yourname = {
    home = "/Users/neiton";
  };

  environment.systemPackages = with pkgs; [
    neovim
  ];

  system.stateVersion = 5;
}
