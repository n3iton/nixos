{ pkgs, ... }:
{
  programs.adb.enable = true;
  users.users.neiton.extraGroups = [ "adbusers" ];

  environment.systemPackages = with pkgs; [
    go-mtpfs
  ];
}
