{ ... }:

{
  # Настройки macOS через `defaults write`. Значения повторяют то, как настроен mac mini.
  system.defaults.finder = {
    FXPreferredViewStyle = "clmv"; # вид колонками
    ShowPathbar = true;
    ShowStatusBar = true;
    ShowExternalHardDrivesOnDesktop = false;
    ShowHardDrivesOnDesktop = false;
    ShowRemovableMediaOnDesktop = true;
  };
}
