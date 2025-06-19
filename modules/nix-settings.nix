{ lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
      "vscode"
      "libfprint-2-tod1-goodix-550a"
    ];

  # Nix Configuration
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
