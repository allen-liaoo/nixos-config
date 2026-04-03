{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.alacritty;
    settings = {
      general.live_config_reload = true;
      window = {
        padding = { x = 10; y = 10; };
        decorations = "None";
      };
      terminal.osc52 = "OnlyCopy"; # for copying from remote server
    };
  };
}
