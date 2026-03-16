{ ... }:

{
  programs.zellij = {
    enable = false;

    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      color_theme = "elementarish";
      theme_background = true;
      truecolor = true;
    };
  };
}
