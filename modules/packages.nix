{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    # list of unfree packages
    obsidian
    vscode
    zoom-us
    google-chrome
    yandex-disk

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
    unstable.ffmpeg
    kubectl
    minikube
    kubernetes-helm

    # clipboard
    cliphist
    wl-clipboard

    # brightness and sound
    brightnessctl

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
    kdePackages.dolphin

    # programming languages and LSP servers
    nixfmt-rfc-style # formatter for nix
    nil # LSP server for nix
    lua-language-server # LSP server for lua
    go # golang
    graphviz
    gcc
    gnumake

    # Cursor theme
    rose-pine-hyprcursor

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
    telegram-desktop # telegram client
    libreoffice # office suite
    thunderbird # Post client and RSS reader
    syncthing # File synchronization
    obs-studio # recording
    mpv # Player
    qalculate-qt # Calculator
    audacity # Audio recording and editing
    calibre # Ebook managment
    rustdesk # Remote desktop
    anydesk
    local.audiorelay
    dbeaver-bin # Database access
    unstable.kdePackages.kdenlive
    xournalpp

    wireguard-tools

  ];

}
