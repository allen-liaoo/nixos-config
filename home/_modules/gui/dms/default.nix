{ lib, inputs, pkgs, aln, ... }:

{
  imports = aln.lib.listDirFiles ./.;
  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = true; # uses dms's dgop
    dgop.package = inputs.dgop.packages.${pkgs.system}.default; # fix for dgop not in nixpkgs stable
    enableVPN = true;
    enableDynamicTheming = true; # metagen
    enableCalendarEvents = false; # khal - need extra setup
    enableClipboardPaste = false; # wtype ; use vicinae for this

    session = {
      wallpaperPath = aln.lib.relToRoot "assets/wallpaper/wallpaper-night.jpg";
    };

    settings = {
      dynamicTheming = true;
      clipboardSettings.disabled = true;

      clockDateFormat = "ddd MMM d"; # weekday month date
      use24HourClock = false;
      showSeconds = false;
      useFahrenheit = false;
      showWorkspaceIndex = false;
      showWorkspaceName = false;
      showWorkspaceApps = false;
      workspaceDragReorder = true;
      centeringMode = "index"; # mode to center bar widgets
      
      controlCenterWidgets = [
        { id = "brightnessSlider"; width = 50; }
        { id = "volumeSlider"; width = 50; }
        { id = "wifi"; width = 50; }
        { id = "inputVolumeSlider"; width = 50; }
        { id = "bluetooth"; width = 50; }
        { id = "audioOutput"; width = 25; }
        { id = "audioInput"; width = 25; }
        { id = "builtin_vpn"; width = 50; }
        { id = "battery"; width = 50; }
        { id = "doNotDisturb"; width = 50; }
        { id = "darkMode"; width = 50; }
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
        squareCorners = true;
        noBackground = true;
        maximizeWidgetIcons = true;
        maximizeWidgetText = false;
        borderEnabled = false;
        widgetOutlineEnabled = false;
        autoHide = false;
        scrollEnabled = false;
    
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
          {
            id = "controlCenterButton";
            showNetworkIcon = true;
            showBluetoothIcon = true;
            showAudioIcon = true;
            showAudioPercent = false;
            showBrightnessIcon = true;
            showBrightnessPercent = false;
            showMicIcon = false;
            showMicPercent = false;
          }
        ];
      }];

      # Cannot figure out how to set position and interval of this widget
      # Bugged: need to set its instance?
      systemMonitorEnabled = false;
      systemMonitorShowHeader = false;
      systemMonitorLayoutMode = "list";
      systemMonitorTransparency = 0.8;
      systemMonitorGraphInterval = 60;
      systemMonitorShowCpu = true;
      systemMonitorShowCpuTemp = true;
      systemMonitorShowGpuTemp = true;
      systemMonitorShowMemory = true;
      systemMonitorShowMemoryGraph = true;
      systemMonitorShowNetwork = true;
      systemMonitorShowNetworkGraph = true;
      systemMonitorShowDisk = false;
      systemMonitorShowTopProcesses = false;
      systemMonitorDisplayPreferences = [ "all" ];
      systemMonitorSyncPositionAcrossScreens = true;
      systemMonitorX = -1;
      systemMonitorY = -1;
    };
  };
}
  # :%s/"\([a-zA-z]\+\)": \([^,]\+\),/\1 = \2;/
