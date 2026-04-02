{ lib, config, inputs, pkgs, aln, ... }:

{
  imports = aln.lib.listDirFiles ./.;

  # WARNING: stylix styling for dms does not exist for stable version of home manager  
  stylix.targets.dank-material-shell.enable = true;

  # dms is ride or die for niri
  systemd.user.services.dms = {
    Unit = {
      After = [ "niri.service" ];
      BindsTo = [ "niri.service" ];
    };
  };

  programs.dank-material-shell = {
    enable = true;

    # wrap in nixGL to fix OpenGL under nix in non-Nixos systems
    package = config.lib.nixGL.wrap inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

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
      blurredWallpaperLayer = false;
      blurredWallpaperOnOverview = true;

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
# convert json kv row to nix
# :%s/"\([a-zA-z]\+\)": \([^,]\+\),/\1 = \2;/
