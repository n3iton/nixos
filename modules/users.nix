{ config, pkgs, ... }:
{
  sops.secrets.my-password.neededForUsers = true;
  sops.secrets.root-password.neededForUsers = true;

  users.users.root.hashedPasswordFile = config.sops.secrets.root-password.path;
  
  users.users.neiton = {
    isNormalUser = true;
    description = "neiton";
    extraGroups = [
      "networkmanager"
      "input"
      "wheel"
      "video"
      "audio"
      "tss"
      "docker"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      yazi
      neovim
    ];

    hashedPasswordFile = config.sops.secrets.my-password.path;
  };

  programs.fish.enable = true;
  programs.kdeconnect.enable = true;
}
