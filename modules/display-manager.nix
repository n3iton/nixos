{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "purple_leaves";
    })
  ];

  # Включаем SDDM как дисплей-менеджер
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    extraPackages = [
      pkgs.kdePackages.qtmultimedia
    ];
    wayland.enable = true; # 👈 это обязательная строка, если не используешь X11
    theme = "sddm-astronaut-theme";
  };

  # Указываем, что будем использовать Hyprland
  services.displayManager.defaultSession = "hyprland-uwsm";
}
