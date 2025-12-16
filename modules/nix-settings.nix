{ lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
      "vscode"
      "zoom"
      "libsciter" # for rustdesk
      "libfprint-2-tod1-goodix-550a"
      "audiorelay"
      "goland"
      "google-chrome"
      "yandex-disk"
    ];

  # Nix Configuration
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
