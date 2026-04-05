{ lib, ... }:

{
  programs.dank-material-shell.settings = {
    clockDateFormat = "ddd MMM d"; # weekday month date
    use24HourClock = false;
    showSeconds = false;
    useFahrenheit = false;

    centeringMode = "index"; # mode to center bar widgets
    showWorkspaceIndex = false;
    showWorkspaceName = false;
    showWorkspaceApps = true;
    showOccupiedWorkspacesOnly = true;
    maxWorkspaceIcons = 3;
    workspaceDragReorder = true;
    workspaceColorMode = "none";
    workspaceOccupiedColorMode = "none";
    workspaceUnfocusedColorMode = "default";
    workspaceUrgentColorMode = "default";
    workspaceFocusedBorderEnabled = true;
    workspaceFocusedBorderColor = "surfaceText";
    workspaceFocusedBorderThickness = 2;
    
    controlCenterWidgets = [
      { id = "brightnessSlider"; width = 50; }
      { id = "volumeSlider"; width = 50; }
      { id = "wifi"; width = 50; }
      { id = "inputVolumeSlider"; width = 50; }
      { id = "bluetooth"; width = 50; }
      { id = "audioOutput"; width = 50; }
      { id = "builtin_vpn"; width = 50; }
      { id = "audioInput"; width = 50; }
      { id = "doNotDisturb"; width = 50; }
      { id = "nightMode"; width = 25; }
      { id = "darkMode"; width = 25; }
    ];

    barConfigs = [{
      id = "default";
      name = "Main Bar";
      enabled = true;
  
      position = 0;
      screenPreferences = [ "all" ];
      spacing = 0;
      innerPadding = -5;
      bottomGap = 0;
      transparency = 0;
      fontScale = 1.35;
      squareCorners = true;
      noBackground = true;
      maximizeWidgetIcons = true;
      maximizeWidgetText = false;
      borderEnabled = false;
      widgetOutlineEnabled = false;
      autoHide = false;
      scrollEnabled = false;
      openOnOverview = true;
  
      leftWidgets = [
        { id = "clock"; }
        { id = "notificationButton"; }
        { id = "music"; }
      ];
      centerWidgets = [
        { id = "workspaceSwitcher"; }
      ];
      rightWidgets = [
        { id = "privacyIndicator"; }
        { id = "systemTray"; }
        { id = "keyboard_layout_name"; keyboardLayoutNameCompactMode = true; }
        { id = "battery"; }
        {
          id = "controlCenterButton";
          showAudioIcon = true;
          showAudioPercent = false;
          showBatteryIcon = false;
          showBluetoothIcon = true;
          showBrightnessIcon = true;
          showBrightnessPercent = false;
          showNetworkIcon = true;
          showMicIcon = false;
          showMicPercent = false;
        }
      ];
    }];
  };
}
