{
  inputs,
  ...
}:
{

  imports = [
    ./hardware-configuration.nix

    ../../modules/internationalisation.nix
    ../../modules/gc.nix
    ../../modules/time.nix
    ../../modules/usb.nix
    ../../modules/linux-kernel.nix
    ../../modules/bootloader.nix
    ../../modules/fingerprint-scanner.nix
    ../../modules/nix-settings.nix
    ../../modules/services.nix
    ../../modules/users.nix
    ../../modules/hyprland.nix
    ../../modules/display-manager.nix
    ../../modules/networking.nix
    ../../modules/virtualisation.nix
    ../../modules/packages.nix
    ../../modules/bluetooth.nix
    ../../modules/sound.nix
    ../../modules/fonts.nix
    ../../modules/swap.nix
    ../../modules/open-ssh.nix
    ../../modules/security.nix
    ../../modules/android.nix
    ../../modules/yubikey.nix
    ../../modules/firmware-update.nix
  ];

  environment.variables.EDITOR = "nvim";

  system.stateVersion = "25.05";
}
