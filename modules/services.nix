{ pkgs, ... }:
{
  services.dbus.enable = true;

  systemd.user.services.battery-check = {
    description = "Battery status checker";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "battery-check" ''
        battery_info="/sys/class/power_supply/BAT0/uevent"
        power_status=$(grep "STATUS=" "$battery_info" | cut -d "=" -f2)
        battery_percentage=$(grep "CAPACITY=" "$battery_info" | cut -d "=" -f2)

        if [[ "$power_status" == "Discharging" && "$battery_percentage" -le 15 ]]; then
            ${pkgs.libnotify}/bin/notify-send -u critical "🔋 Battery Low"
        fi
      ''}";
    };
  };

  systemd.user.timers.battery-check = {
    description = "Run battery-check every 5 min";
    wantedBy = [ "default.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
  };

}
