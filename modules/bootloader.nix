{ pkgs, ... }:
{

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 2;
  boot.initrd.enable = true;
  boot.initrd.verbose = false;
  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [ "i915" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.consoleLogLevel = 3;
  boot.plymouth = {
    enable = true;
    font = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf";
  };

  boot.blacklistedKernelModules = [ "ntfs3" ]; # For mounting ntfs in thunar
}
