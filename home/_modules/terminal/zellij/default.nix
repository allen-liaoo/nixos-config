{ config, alnLib, ... }:

{
  programs.zellij = {
    enable = true;
    # below auto-starts zellij
    #enableBashIntegration = true;
    #enableFishIntegration = true;
    #enableZshIntegration = true;
  };

  xdg.configFile."zellij/config.kdl".source = config.lib.file.mkOutOfStoreSymlink (alnLib.outOfStoreRelToRoot config.home.homeDirectory ./config.kdl);
}
