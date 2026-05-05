{ ... }:

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
    };
  };
}
