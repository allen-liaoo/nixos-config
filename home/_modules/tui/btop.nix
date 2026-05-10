{ config, ctx, ... }:

{
  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
      truecolor = true;
    };
  };

  aln.matugen.template."btop" = {
    enable = ctx.host.is.gui;
    content = {
      input_path = config.aln.matugen.themesPath "btop.theme";
      output_path = "${config.xdg.configHome}/btop/themes/mutagen.theme";
      post_hook = "pkill -USR2 btop || true";
    };
  };

  programs.btop.settings.color_theme = "matugen";
}
