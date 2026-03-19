# Templates for quadlet units
# see https://seiarotg.github.io/quadlet-nix/home-manager-options.html for options
{...}:

{
  mkContainer = (name: config: {
    autoStart = true;
    containerConfig = {
      inherit name;
      autoUpdate = "registry";
      logDriver = "journald";
      noNewPrivileges = true;
      startWithPod = true;
    };
    unitConfig = {
      # Dont limit restarts
      StartLimitIntervalSec = 0;
    };
    serviceConfig = {
      Restart = "always";
      RestartSec = "30min";
    };
    quadletConfig.defaultDependencies = true;
  } // config);

  mkImage = (name: config: {
    autoStart = true;
    imageConfig = {
      name = "${name}-image";
      retry = 3;
    };
    unitConfig = {
      StartLimitIntervalSec = 0;
    };
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "1min";
    };
  } // config);
 
  mkNetwork = (name: config: {
    autoStart = true;
    networkConfig = {
      name = "${name}-network";
      disableDns = false;
    };
    unitConfig = {
      # Dont limit restarts
      StartLimitIntervalSec = 0;
    };
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5min";
    };
  } // config);

  mkPod = (name: config: {
    autoStart = true;
    networkConfig = {
      name = "${name}-pod";
      disableDns = false;
      exitPolicy = "stop";
      stopTimeout = "120"; # kill units after timeout
    };
    unitConfig = {
      # Dont limit restarts
      StartLimitIntervalSec = 0;
    };
    serviceConfig = {
      Restart = "always";
      # with exitPolicy = stop, pod exists cleanly when all the container stops,
      # does not matter if container stops with failure. so set this as always
      RestartSec = "15min";

    };
  } // config);

  mkVolume = (name: config: {
    autoStart = true;
    volumeConfig = {
      name = "${name}-volume";
      copy = true;
      device = "tmpfs";
    };
    unitConfig = {
      # Dont limit restarts
      StartLimitIntervalSec = 0;
    };
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5min";
    };
  } // config);
}
