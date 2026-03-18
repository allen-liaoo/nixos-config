{ ... }:

{
  programs.btop = {
    enable = true;

    themes.elementarish = builtins.readFile ./elementarish.theme;

    settings = {
      color_theme = "elementarish";
      theme_background = true;
      truecolor = true;
    };
  };
}
