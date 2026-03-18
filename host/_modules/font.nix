{ pkgs, ... }:

{
  fonts = {
    # enable if needing other languages
    #enableDefaultPackages = true;

    packages = with pkgs; [
      nerd-fonts.commit-mono # for terminal
      nerd-fonts.fira-code # for code

      # system fonts
      adwaita-fonts 
      dejavu_fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "DejaVu Serif" "Noto Serif CJK TC" "Noto Serif CJK SC" ];
        sansSerif = [ "Adwaita Sans" "Noto Sans CJK TC" "Noto Sans CJK SC" ];
        monospace = [ "Commit Mono" "Noto Sans Mono CJK SC" "Noto Sans Mono CJK TC" ];
      };
    };
  };
}
