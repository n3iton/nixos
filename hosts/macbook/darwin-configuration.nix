{ pkgs, ... }:

{
  nix.enable = false;

  users.users.nikita = {
    home = "/Users/nikita";
  };

  system.primaryUser = "nikita";

  homebrew = {
    enable = true;
    
    casks = [
      "loop-messenger"
      "docker-desktop"
      "firefox"
      "kontur-talk"
    ];
  };
  
  system.stateVersion = 5;
}
