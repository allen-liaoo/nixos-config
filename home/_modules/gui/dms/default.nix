{ lib, inputs, pkgs, aln, ... }:

{
  imports = aln.lib.listDirFiles ./.;

  stylix.targets.dank-material-shell.enable = true;

  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = true; # uses dms's dgop
    dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default; # fix for dgop not in nixpkgs stable
    enableVPN = true;
    enableDynamicTheming = false; # mutagen ; use stylix
    enableCalendarEvents = false; # khal - need extra setup
    enableClipboardPaste = false; # wtype ; use vicinae for this

    #session = {
      #wallpaperPath = aln.lib.relToRoot "assets/wallpaper/wallpaper-night.jpg";
    #};

    settings = {
      dynamicTheming = true;
      clipboardSettings.disabled = true;

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
