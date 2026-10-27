{ ... }:

{
  # Настройки macOS через `defaults write`. Часть повторяет то, как настроен mac mini,
  # часть — осознанные изменения поверх него (помечены).
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0; # изменение: Dock появляется без задержки
      magnification = true;
      largesize = 60;
      tilesize = 47;
      show-recents = false; # изменение: без недавних приложений
      wvous-br-corner = 1; # изменение: правый нижний угол без действия (было «Быстрая заметка»)
      persistent-apps = [
        "/System/Applications/System Settings.app"
        "/Applications/Firefox.app"
        "/System/Applications/Utilities/Terminal.app"
        "/Applications/Visual Studio Code.app"
      ];
      persistent-others = [
        {
          folder = {
            path = "/Users/nikita/Downloads";
            arrangement = "date-added";
            displayas = "stack";
            showas = "fan";
          };
        }
      ];
    };

    finder = {
      FXPreferredViewStyle = "clmv"; # вид колонками
      ShowPathbar = true;
      ShowStatusBar = true;
      ShowExternalHardDrivesOnDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      # изменения:
      AppleShowAllFiles = true; # показывать скрытые файлы (то же, что Cmd+Shift+.)
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;
      FXDefaultSearchScope = "SCcf"; # искать в текущей папке
    };

    NSGlobalDomain = {
      # «естественная» прокрутка задаётся в hosts/<host>: она же определяет направление
      # свайпа между рабочими столами, а устройства ввода на маках разные
      # изменения:
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true; # скрытые файлы и в окнах «Открыть»/«Сохранить» других программ
      "com.apple.mouse.tapBehavior" = 1; # касание = клик, в том числе на экране входа
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
    };

    trackpad.Clicking = true; # изменение: касание = клик

    hitoolbox.AppleFnUsageType = "Change Input Source"; # 🌐 переключает раскладку

    WindowManager = {
      EnableTiledWindowMargins = false;
      StandardHideWidgets = true;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

    CustomUserPreferences = {
      # изменение: не мусорить .DS_Store на сетевых и USB-дисках
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      # Раскладки ABC и Russian – PC, как на mac mini; применяются после перелогина
      "com.apple.HIToolbox".AppleEnabledInputSources = [
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 252;
          "KeyboardLayout Name" = "ABC";
        }
        {
          "Bundle ID" = "com.apple.CharacterPaletteIM";
          InputSourceKind = "Non Keyboard Input Method";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 19458;
          "KeyboardLayout Name" = "RussianWin";
        }
        {
          "Bundle ID" = "com.apple.PressAndHold";
          InputSourceKind = "Non Keyboard Input Method";
        }
        {
          "Bundle ID" = "com.apple.inputmethod.ironwood";
          InputSourceKind = "Non Keyboard Input Method";
        }
      ];
    };
  };
}
