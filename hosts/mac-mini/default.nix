{ ... }:

{
  imports = [ ../../modules/darwin/common.nix ];

  home-manager.users.nikita = {
    imports = [ ../../home/common.nix ];
  };
}
