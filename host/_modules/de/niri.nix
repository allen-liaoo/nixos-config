{ pkgs-unstable, ... }:

{
  programs.niri = {
    enable = true;
    package = pkgs-unstable.niri;
  };
  hardware.graphics.enable = true;
}
