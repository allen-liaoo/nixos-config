{ config, alnLib, ... }:

{
  programs.fastfetch = {
    enable = true;
  };

  xdg.configFile."fastfetch/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink (alnLib.outOfStoreRelToRoot config.home.homeDirectory ./config.jsonc);
}
