{ config, alnLib, ... }:

let
  configKdl = "zellij/config.kdl";
in
{
  programs.zellij = {
    enable = true;
    # below auto-starts zellij
    #enableBashIntegration = true;
    #enableFishIntegration = true;
    #enableZshIntegration = true;
  };

  programs.fish.shellAbbrs = {
    zj = "zellij";
  };

  xdg.configFile.${configKdl}.source = config.lib.file.mkOutOfStoreSymlink (
    alnLib.outOfStoreRelToRoot config.home.homeDirectory ./config.kdl
  );

  aln.matugen.template."zellij" = {
    enable = config.programs.zellij.enable;
    content = {
      input_path = config.aln.matugen.themesPath "zellij-theme.kdl.tera";
      output_path = config.xdg.configHome + "/zellij/themes/matugen.kdl";
      post_hook = "touch ${configKdl}"; # live reload
    };
  };
}
