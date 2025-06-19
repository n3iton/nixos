{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
  ];
  security.unprivilegedUsernsClone = true;
}
