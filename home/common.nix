{ pkgs, ... }:

{
  home.username = "nikita";
  home.homeDirectory = "/Users/nikita";

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    nixd
    unstable.clickhouse
    ayugram-desktop
  ];

}
