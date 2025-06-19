{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # Nerd Fonts (замена nerdfonts.override)
    # nerd-fonts.caskaydia-cove
    # nerd-fonts.caskaydia-mono
    # nerd-fonts.fira-code
    # nerd-fonts.fira-mono
    # nerd-fonts.fira-sans
    # nerd-fonts.firacode
    # nerd-fonts.iosevka
    # nerd-fonts.iosevka-term
    nerd-fonts.jetbrains-mono
    # nerd-fonts.nerd-fonts-symbols
    # nerd-fonts.nerd-fonts-symbols-mono

    # Дополнительно
    font-awesome
  ];
}
