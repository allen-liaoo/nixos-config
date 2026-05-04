{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    nerd-fonts.commit-mono
    nerd-fonts.fira-code

    # system fonts
    adwaita-fonts 
    dejavu_fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "DejaVu Serif" "Noto Serif CJK TC" "Noto Serif CJK SC" ];
      sansSerif = [ "Adwaita Sans" "Noto Sans CJK TC" "Noto Sans CJK SC" ];
      monospace = [ "CommitMono Nerd Font Mono" "FiraCode Nerd Font Mono" "Noto Sans Mono CJK TC" "Noto Sans Mono CJK SC" ];
    };
  };
}
