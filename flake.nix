{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      # Общий overlay, добавляющий "unstable" пакеты в стабильный pkgs
      unstableOverlay =
        final: prev:
        let
          unstablePkgs = import nixpkgs-unstable {
            system = prev.system;
            config.allowUnfree = true;
          };
        in
        {
          unstable = unstablePkgs; # доступ к ним через pkgs.unstable.*
        };

      # Локальный overlay, добавляющий собственные пакеты в pkgs.local.*
      localOverlay =
        final: prev:
        let
          localPkgs = {
            audiorelay = prev.callPackage ./pkgs/audiorelay.nix { };
          };
        in
        {
          local = localPkgs; # доступ к ним через pkgs.local.*
        };
    in
    {
      nixosConfigurations = {
        t490s = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/t490s/configuration.nix

            (
              { pkgs, lib, ... }:
              {
                nixpkgs.overlays = [
                  unstableOverlay
                  localOverlay
                ];
              }
            )
          ];
        };

        x280 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/x280/configuration.nix
          ];
        };

      };
    };
}
