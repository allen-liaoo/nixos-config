# Should run xremap as non root, otherwide programs get launched as root
{ lib, aln, ... }:

lib.optionalAttrs (with aln.ctx.user.inGroup; input && wheel) {
  services.xremap = {
    enable = true;
    #withNiri = true;
    #userName = aln.ctx.user.name;

    # Modmap for single key rebinds
    config.modmap = [
      {
        name = "Space as meta";
        remap."SPACE" = {
          held = "LEFTMETA";
          alone = "SPACE"; # when released or timeout reached
          free_hold = true;
          #alone_timeout_millis = "1000"; #ms # doesnt seem to work
        };
      }
    ] ++ 
    lib.optionals (aln.ctx.host.equals aln.inventory.hosts.theseus) [{
      name = "Swap alt and ctrl on fw13 keyboard";
      remap = {
        "LEFTALT" = "LEFTCTRL";
        "RIGHTALT" = "RIGHTCTRL";
      };
      device.only = "AT Translated Set 2 keyboard";
    }];
  };
}

