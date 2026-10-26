{ pkgs, ... }:
{
  # programs.adb убран в NixOS 26.05: udev-правила для устройств теперь даёт systemd,
  # поэтому достаточно самого adb, а группа adbusers больше не нужна
  environment.systemPackages = with pkgs; [
    android-tools
    go-mtpfs
  ];
}
