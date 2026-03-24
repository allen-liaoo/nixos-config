{ lib, ... }:

{
  programs.fastfetch = {
    enable = true;
  };

  xdg.configFile."fastfetch/config.jsonrc".source = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./config.jsonrc);
}
