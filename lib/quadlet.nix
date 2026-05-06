# Templates for quadlet units
# see https://seiarotg.github.io/quadlet-nix/home-manager-options.html for options
{ lib, ... }:

let 
  restartDefault = {
    unitConfig = {
      StartLimitIntervalSec = 0;
    };
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
      RestartSteps = 6; # rate of exponential timeout
      RestartMaxDelaySec = "5min"; # max timeout
      TimeoutStartSec = 1000;
    };
  };
in {
  mkContainer = (name:
    lib.recursiveUpdate ({
      autoStart = true;
      containerConfig = {
        inherit name;
        userns = "auto";
        autoUpdate = "registry";
        logDriver = "journald";
        noNewPrivileges = true;
        startWithPod = true;
      };
      quadletConfig.defaultDependencies = true;
    } // restartDefault));

  mkImage = ( 
    lib.recursiveUpdate ({
      autoStart = true;
      imageConfig.retry = 3;
    } // restartDefault));
 
  mkNetwork = (name:
    lib.recursiveUpdate ({
      autoStart = true;
      networkConfig = {
        name = "${name}-network";
        disableDns = false;
      };
    } // restartDefault));

  mkPod = (name:
    lib.recursiveUpdate ({
      autoStart = true;
      podConfig = {
        name = name; # can't add -pod postfix as pod name must be unique, so postfix must be in the input name
        userns = "auto";
        exitPolicy = "stop";
        stopTimeout = 120; # kill units after timeout
      };
      serviceConfig = {
        Restart = "always";
        # with exitPolicy = stop, pod exists cleanly when all the container stops,
        # does not matter if container stops with failure. so set this as always
        RestartSec = "15min";
      };
    } // restartDefault));

  mkVolume = (name:
    lib.recursiveUpdate ({
      autoStart = true;
      volumeConfig = {
        name = "${name}-volume";
      };
    } // restartDefault));
}
