{
  config,
  lib,
  pkgs,
  ...
}:

let
  dmsEnabled = config.programs.dank-material-shell.enable;
in
# https://danklinux.com/docs/dankmaterialshell/application-themes
{
  programs.dank-material-shell.settings = lib.mkIf dmsEnabled {
    runUserMatugenTemplates = true;
    runDmsMatugenTemplates = true;
    matugenTemplateAlacritty = true;
    matugenTemplateDgop = true;
    matugenTemplateFirefox = true;
    matugenTemplateGtk = true;
    matugenTemplateNiri = true;
    # matugenTemplatePywalfox = true;
    # matugenTemplateQt5ct = true; # Qt uses GTK theme
    # matugenTemplateQt6ct = true;
    matugenTemplateVesktop = true;
    # matugenTemplateVscode = true;
  };

  programs.alacritty = lib.mkIf dmsEnabled {
    settings.general.import = [
      (config.xdg.configHome + "/alacritty/dank-theme.toml")
    ];
  };

  # firefox (pywalfox)
  # pywalfox extension is installed at firefox configs
  home.packages = lib.mkIf dmsEnabled [ pkgs.pywalfox-native ];
  home.activation = {
    pywalfoxInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${lib.getExe pkgs.pywalfox-native} install
    '';
  };
  home.file.".cache/wal/colors.json".source = lib.mkIf dmsEnabled (config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/.cache/wal/dank-pywalfox.json"));

  # niri
  xdg.configFile."niri/config.kdl".text = ''
    include "dms/colors.kdl"
  '';

  programs.vesktop = lib.mkIf dmsEnabled {
    vencord.settings.enabledThemes = [
     "dank-discord.css"
    ];
  };
}
