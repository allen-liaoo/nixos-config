{
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.adw-gtk3 # for theming gtk
  ];

  programs.dank-material-shell.settings = {
    blurEnabled = true;
    blurBorderOpacity = 0;
    popupTransparency = 0.4;
    syncModeWithPortal = true;
    currentThemeName = "dynamic";
    currentThemeCategory = "dynamic";
    matugenScheme = "scheme-tonal-spot";
    blurredWallpaperLayer = false;
    blurredWallpaperOnOverview = true;

    # DMS managed matugen themes
    # https://danklinux.com/docs/dankmaterialshell/application-themes
    runUserMatugenTemplates = true;
    runDmsMatugenTemplates = true;
    matugenTemplateDgop = true;
    matugenTemplateGtk = true;
    matugenTemplateNiri = true;
    # matugenTemplateQt5ct = true; # Qt uses GTK theme
    # matugenTemplateQt6ct = true;
    # matugenTemplateVscode = true;
  };
}
