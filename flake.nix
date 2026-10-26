{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      darwin,
      home-manager,
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

      # Общий конструктор для маков: отличается только модулем хоста
      mkDarwin =
        hostModule:
        darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            hostModule
            ./modules/nix-settings.nix
            ./modules/fonts.nix
            home-manager.darwinModules.home-manager

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }

            (
              { ... }:
              {
                nixpkgs.overlays = commonOverlays;
              }
            )
          ];
        };
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
      darwinConfigurations = rec {
        mac-mini = mkDarwin ./hosts/mac-mini;
        macbook-air = mkDarwin ./hosts/macbook-air;

        # Старое имя, чтобы `--flake .#macbook` на mac mini продолжал работать
        macbook = mac-mini;
      };
    };
}
