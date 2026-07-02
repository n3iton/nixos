{ pkgs, ... }:

{
  nix.enable = false;

  users.users.nikita = {
    home = "/Users/nikita";
  };

  system.primaryUser = "nikita";

  programs.fish.enable = true;

  environment.shells = [ pkgs.fish ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };

    casks = [
      "loop-messenger"
      "docker-desktop"
      "firefox"
      "kontur-talk"
      "soduto"
      "happ"
      "visual-studio-code"
      "zoom"
      "monitorcontrol"
      "cursor"
      "keepassxc"
      "obsidian"
    ];

    brews = [
      "kubebuilder"
      "go-task"
      "werf"
      "yq"
      "trivy"
      "pre-commit"
      "syncthing"
      "starship"
      "nixfmt"
      "go"
      "tmux"
      "neovim"
      "tealdeer"
      "tree"
      "dive"
      "stow"
      "go-task"
      "crane"
    ];
  };

  system.stateVersion = 5;
}
