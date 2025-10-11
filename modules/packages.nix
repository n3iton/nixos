{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    # list of unfree packages
    obsidian
    vscode
    zoom-us

    # Terminal utilitues
    curl
    git
    neovim
    stow
    tmux
    btop
    tree
    fastfetch
    ripgrep
    tealdeer
    starship
    zip
    unzip

    # clipboard
    cliphist
    wl-clipboard

    # brightness and sound
    brightnessctl
    pamixer

    # screenshots
    grim
    slurp
    swappy

    # desktop environment
    waybar # status bar
    dunst # notifications
    wlogout # logout menu
    rofi # app launcher

    # file manager
    xfce.thunar

    # networking
    networkmanagerapplet

    # bluetooth
    bluez
    blueman

    # programming languages and LSP servers
    nixfmt-rfc-style # formatter for nix
    nil # LSP server for nix
    lua-language-server # LSP server for lua
    go # golang
    gcc
    gnumake

    # Cursor theme
    rose-pine-hyprcursor

    # fingerprint scanner
    libfprint
    fprintd

    e2fsprogs

    sops

    # backups
    restic
    rclone

    # GUI programs
    librewolf # browser
    chromium
    keepassxc # password manger
    kitty # terminal emulator
    qbittorrent # torrent client
    ayugram-desktop # telegram client
    libreoffice # office suite
    thunderbird # Post client and RSS reader
    syncthing # File synchronization
    obs-studio # recording
    mpv # Player
    qalculate-qt # Calculator
    audacity # Audio recording and editing
    calibre # Ebook managment
    rustdesk # Remote desktop
    nur.repos.slaier.audiorelay

    # android MTP
    go-mtpfs

    wireguard-tools
  ];

}
