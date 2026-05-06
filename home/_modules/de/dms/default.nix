{ lib, config, inputs, pkgs, alnLib, inventory, ctx, ... }:

let
  # wrap in nixGL to fix OpenGL under nix in non-Nixos systems
  dms-pkg = config.lib.nixGL.wrap inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = alnLib.listDirFiles ./. ++ [
    inputs.dms.homeModules.dank-material-shell
  ];

  # dms is ride or die for niri
  # systemd.user.services.dms = {
  #   Unit = {
  #     After = [ "niri.service" ];
  #     BindsTo = [ "niri.service" ];
  #   };
  # };

  programs.dank-material-shell = {
    enable = true;

    package = dms-pkg; # wait for this option to be changed in nixos stable

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    # managePluginSettings = true;
    # plugins = { };

    enableSystemMonitoring = true; # uses dms's dgop
    dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default; # fix for dgop not in nixpkgs stable
    enableVPN = true;
    enableDynamicTheming = true; # mutagen
    enableCalendarEvents = false; # khal ; need extra setup
    enableClipboardPaste = false; # wtype ; use vicinae for this

    session = {
      showThirdPartyPlugins = true;
      wallpaperPath = alnLib.relToRoot "assets/wallpaper/roadtrip.jpg";
    };

    settings = {
      blurEnabled = true;
      blurBorderOpacity = 0;
      popupTransparency = 0.4;
      currentThemeName = "dynamic";
      currentThemeCategory = "dynamic";
      matugenScheme = "scheme-expressive";
      blurredWallpaperLayer = false;
      blurredWallpaperOnOverview = true;

      enableFprint = ctx.host.equals inventory.hosts.theseus; # TODO: refactor or keep track of this
      maxFprintTries = 8;
      loginctlLockIntegration = true;
      lockBeforeSuspend = true;
      fadeToLockEnabled = true; # fade to lock screen before locking
      fadeToLockGracePeriod = 5; # sec
      fadeToDpmsEnabled = true; # fade to lock screen before turning off monitors
      fadeToDpmsGracePeriod = 5;

      # automatic lock, turn off monitor, or suspend (sec)
      batteryLockTimeout = 180;
      batteryMonitorTimeout = 300;
      batterySuspendTimeout = 600;
      batterySuspendBehavior = 0; # 0: suspend, 1: hibernate, 2: suspend then hibernate
      acLockTimeout = 300;
      acMonitorTimeout = 600;
      acSuspendTimeout = 1800;
      acSuspendBehavior = 0;
      powerMenuDefaultAction = "lock";

      clipboardSettings.disabled = true;
      displayNameMode = "model"; # recognize monitors by model rather than name

      niriOverviewOverlayEnabled = false; # disable dms launcher
      appIdSubstitutions = [];

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
# :%s/"\([a-zA-z0-9]\+\)": \([^,]\+\),/\1 = \2;/
