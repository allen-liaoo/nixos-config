{
  config,
  inputs,
  pkgs,
  pkgs-unstable,
  alnLib,
  inventory,
  ctx,
  ...
}:

let
  # wrap in nixGL to fix OpenGL under nix in non-Nixos systems
  dms-pkg = config.lib.nixGL.wrap inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = alnLib.listDirFiles ./. ++ [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms-plugin-registry.modules.default
  ];

  programs.dank-material-shell = {
    enable = true;
    package = dms-pkg; # wait for this option to be changed in nixos stable

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableVPN = true;
    enableSystemMonitoring = true; # uses dms's dgop
    dgop.package = pkgs-unstable.dgop;
    enableDynamicTheming = true; # mutagen
    enableAudioWavelength = true;
    enableCalendarEvents = false; # khal ; need extra setup
    enableClipboardPaste = false; # wtype ; use vicinae for this

    settings = {
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

      weatherEnabled = true;
      useAutoLocation = true;
      
      # popoutAnimationSpeed = 4; # custom
      # popoutCustomAnimationDuration = 50;

      niriOverviewOverlayEnabled = false; # disable dms launcher
      appIdSubstitutions = [ ];
    };

    session = {
      showThirdPartyPlugins = true;
      wallpaperPath = alnLib.relToRoot "assets/wallpaper/the-wind-rises.jpg";
    };

    plugins = {
      dankBatteryAlerts.enable = true;
      ddcBrightness.enable = ctx.user.inGroup.i2c;
    };

    # niri = {
    #   enableSpawn = false;
    #   enableKeybinds = false;
    #   includes.enable = false;
    # };
  };

  # dms is ride or die for niri
  systemd.user.services.dms = {
    Unit = {
      After = [ "niri.service" ];
      BindsTo = [ "niri.service" ];
    };
  };

  aln.niri = {
    configFile."dms" = {
      enable = true;
      content = ''
        include "${config.lib.file.mkOutOfStoreSymlink (alnLib.outOfStoreRelToRoot config.home.homeDirectory ./dms.kdl)}"
      '';
    };
    # place below in config since the filepath is relative to niri's config.kdl
    config = ''
      include "dms/alttab.kdl"
      include "dms/outputs.kdl" // displays
      include "dms/wpblur.kdl"  // blurring wallpaper settings
      include "dms/colors.kdl"  // niri colors managed by dms matugen theme
    '';
  };
}
# convert json kv row to nix
# :%s/"\([a-zA-z0-9]\+\)": \([^,]\+\),/\1 = \2;/
