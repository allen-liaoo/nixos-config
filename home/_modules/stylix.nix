{ lib, pkgs, aln, ...}:

{
  # default specialization: night theme
  stylix = {
    enable = true;
    autoEnable = true; # auto enable targets
    base16Scheme = "${pkgs.base16-schemes}/share/themes/snazzy.yaml";
    polarity = "dark";

    # Prevent having to pull in dconf to solve
    # https://github.com/nix-community/stylix/issues/139
    targets.gtk.enable = aln.ctx.host.is.gui;


  } // lib.optionalAttrs aln.ctx.host.is.gui {
    image = aln.lib.relToRoot "assets/wallpaper/wallpaper-night.jpg";
    imageScalingMode = "fill";

    cursor = {
      package = pkgs.vimix-cursors;
      name = "Vimix-cursors";
      size = 14;
    };

    icons = {
      enable = true;
      package = pkgs.whitesur-icon-theme;
      dark = "Whitesur";
      light = "Whitesur";
    };

    # stylix also adds fonts to certain programs who don't read from fontconfig
    # but stylix doesnt support fallbacks (for now)
    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "Dejavu Serif";
      };
      sansSerif = {
        package = pkgs.adwaita-fonts;
        name = "Adwaita Sans";
      };
      monospace = {
        package = pkgs.nerd-fonts.commit-mono;
        name = "Commit Mono Nerd Font";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  # Theme toggling via specialisations does not work well because 
  # DMS, alacritty, etc. doesn't support live reload for when the config symlink'ed to changes
  # They still see the old config
  # home.packages = [
  #   (lib.lowPrio (pkgs.writeShellApplication {
  #     name = "toggle-theme";
  #     runtimeInputs = with pkgs; [ home-manager coreutils ripgrep fish ];
  #     text = ''
  #       "$(home-manager generations | head -1 | rg -o '/[^ ]*')"/specialisation/theme-light/activate
  #     '';
  #   }))
  # ];

  # specialisation.theme-light.configuration = {
  #   stylix = {
  #     base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/tokyo-city-light.yaml";
  #     polarity = lib.mkForce "light";
  
  #   } // lib.optionalAttrs aln.ctx.host.is.gui {
  #     image = lib.mkForce (aln.lib.relToRoot "assets/wallpaper/wallpaper-day.jpg");
  #   };

  #   home.packages = [
  #     (pkgs.writeShellApplication {
  #       name = "toggle-theme";
  #       runtimeInputs = with pkgs; [ home-manager coreutils ripgrep ];
  #       text = ''
  #         "$(home-manager generations | head -2 | tail -1 | rg -o '/[^ ]*')"/activate
  #       '';
  #     })
  #   ];
  # };
}
