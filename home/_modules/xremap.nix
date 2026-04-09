# NOTE: xremaps keys across user boundaries
# Dont move to system module because system xremap service on Niri is untested
# SHOULD NOT LAUNCH PROGRAMS with xremap; use WM
# as program launches as same user as xremap (except xremap as system socket service)
{ lib, aln, ... }:

let
  shouldEnable = !aln.ctx.host.is.server && (with aln.ctx.user.inGroup; input && wheel);
in
{
  services.xremap = {
    enable = shouldEnable; # not guarding the whole module to prevent warning
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
        "LEFTCTRL" = "LEFTALT";
        "RIGHTALT" = "RIGHTCTRL";
        "RIGHTCTRL" = "RIGHTALT";
      };
      device.only = "AT Translated Set 2 keyboard";
    }];

    config.keymap = [{
      name = "Shift+capslock as capslock";
      remap."SHIFT-CAPSLOCK" = "CAPSLOCK";
    }];
  };
}

