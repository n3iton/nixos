{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sops-nix.url = "github:Mic92/sops-nix";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";
    
  };

  outputs =
    {
      self,
      nixpkgs,
      lanzaboote,
      nur,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        t490s = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/t490s/configuration.nix

            lanzaboote.nixosModules.lanzaboote

            (
              { pkgs, lib, ... }:
              {
                # Подключаем overlay NUR
                nixpkgs.overlays = [ nur.overlays.default ];

                environment.systemPackages = [
                  pkgs.sbctl
                ];

                boot.loader.systemd-boot.enable = lib.mkForce false;

                boot.lanzaboote = {
                  enable = true;
                  pkiBundle = "/var/lib/sbctl";
                };
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
