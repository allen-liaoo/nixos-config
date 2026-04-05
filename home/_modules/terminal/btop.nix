{ lib, ... }:

{
  programs.btop = {
    enable = true;
    settings = {
      theme_background = true;
      truecolor = true;
    };
  };
}
