{ pkgs, ... }:

{
  home.username = "nikita";
  home.homeDirectory = "/Users/nikita";

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    keepassxc
    syncthing
    starship
    vscode
    postman

    nil
    nixfmt

    unstable.go

    ghostty-bin

    tmux
    fish
    neovim

    tealdeer
    tree

    obsidian

    librewolf
  ];

}
