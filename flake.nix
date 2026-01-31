{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      darwin,
      ...
    }@inputs:
    let
      # ===== overlays =====

      # Добавляет pkgs.unstable.*
      unstableOverlay =
        final: prev:
        let
          unstablePkgs = import nixpkgs-unstable {
            system = prev.system;
            config.allowUnfree = true;
          };
        in
        {
          unstable = unstablePkgs;
        };

      # Локальные пакеты: pkgs.local.*
      localOverlay = final: prev: {
        local = {
          audiorelay = prev.callPackage ./pkgs/audiorelay.nix { };
        };
      };

      commonOverlays = [
        unstableOverlay
        localOverlay
      ];
    in
    {
      # ===== NixOS =====
      nixosConfigurations = {
        t490s = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/t490s/configuration.nix

            (
              { ... }:
              {
                nixpkgs.overlays = commonOverlays;
              }
            )
          ];
        };
      };

      # ===== macOS (nix-darwin) =====
      darwinConfigurations = {
        macbook = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/macbook/darwin-configuration.nix
            ./modules/nix-settings.nix

            (
              { ... }:
              {
                nixpkgs.overlays = commonOverlays;
              }
            )
          ];
        };
      };
    };
}
