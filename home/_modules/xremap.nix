# TODO: Move to NixOS Module
# It doesnt make sense as a hm module because it remaps keys across user boundaries
# SHOULD NOT LAUNCH PROGRAMS with xremap; use WM
# run as root: programs always launch as root
# run as user: programs always launch as one user
{ lib, aln, ... }:

lib.optionalAttrs (!aln.ctx.host.is.server && (with aln.ctx.user.inGroup; input && wheel)) {
  services.xremap = {
    enable = true;
    withNiri = true;
    watch = true; # watch for devices
    mouse = true; # watch for mouse

    # Modmap for single key rebinds
    config.modmap = [
      {
        name = "Space as meta";
        remap."SPACE" = {
          held = "LEFTMETA";
          alone = "SPACE";
          free_hold = true; # when released, treat as alone
        };
      }
      {
        name = "Capslock as esc";
        remap."CAPSLOCK" = {
          held = "CAPSLOCK";
          alone = "ESC";
          alone_timeout_millis = 200; # if held for this ms or longer, then treat as held
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

    config.keymap = [{
      name = "Shift+capslock as capslock";
      remap."SHIFT-CAPSLOCK" = "CAPSLOCK";
    }];
  };
}

