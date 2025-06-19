{ pkgs, ... }:
{
  swapDevices = [
    {
      device = "/.swapvol/swapfile";
    }
  ];
}
