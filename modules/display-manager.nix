{ ... }:

{
  # Включаем SDDM как дисплей-менеджер
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # 👈 это обязательная строка, если не используешь X11
    theme = "maldives";
  };

  # Указываем, что будем использовать Hyprland
  services.displayManager.defaultSession = "hyprland-uwsm";
}
