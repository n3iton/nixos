{ pkgs, ... }:
{
  users.users.root.hashedPassword = "$6$yRsXfD2g5BJRD2I7$FchaWAER8VbHKHi7xguodKke1Tvnrc4Jssqi74NO2S7A4p5QDfMGadcyrPLKxqBha84VdXiMhZi1rTjvMa7Hh1";

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

    hashedPassword = "$6$wX2aRSYWbRJBqOB6$1WO0a1L25cnfLrY371Ulg3TbfwbuZeuEABHR4VJjJoiUW6AMG5t.vqNYPGCoGqV9uHCqlehJhD3Z18f/GYFNR0";
  };

  programs.fish.enable = true;
  programs.kdeconnect.enable = true;
}
