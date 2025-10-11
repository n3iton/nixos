{ ... }:
{
  networking.networkmanager.enable = true;
  # networking.wg-quick.interfaces.wg0.configFile = "/home/neiton/Downloads/wg0.conf";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      59100
    ];
    allowedUDPPorts = [
      59100
    ];
  };
}
