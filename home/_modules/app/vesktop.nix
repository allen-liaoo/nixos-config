{
  lib,
  config,
  ...
}:

{
  programs.vesktop = {
    enable = true;
    settings = {
      tray = false;
      minimizeToTray = false;
      autoStartMinimized = false;
    };
    vencord.settings = {
      autoUpdate = false;
      autoUpdateNotification = false;
      useQuickCss = true;
      enabledThemes = lib.optionals config.programs.dank-material-shell.enable [
        "dank-discord.css" # dms managed matugen theme
      ];
    };
  };
  programs.dank-material-shell.settings.matugenTemplateVesktop = true;
}
