{ pkgs, ... }:

{
  home.username = "nikita";
  home.homeDirectory = "/Users/nikita";

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    keepassxc
  ];

  programs.fish.enable = true;
}