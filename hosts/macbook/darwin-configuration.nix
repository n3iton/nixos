{ pkgs, ... }:

{
  nix.package = pkgs.nix;
  services.nix-daemon.enable = true;

  users.users.yourname = {
    home = "/Users/neiton";
  };

  environment.systemPackages = with pkgs; [
    neovim
  ];

  system.stateVersion = 5;
}
