{ ... }:
{
  programs.adb.enable = true;
  users.users.neiton.extraGroups = [ "adbusers" ];
}
