{
  lib,
  pkgs,
  ctx,
  ...
}:

let
  grp = "i2c";
  # cant simply check config.groups.i2c because hardware.i2c references it (infinite rec)
  enable = ctx.host.users |> map (u: u.groups) |> lib.flatten |> builtins.elem grp;
in
{
  hardware.i2c = {
    enable = enable;
    group = grp; # give this group access
  };

  environment.systemPackages = lib.mkIf enable (with pkgs; [
    ddcutil
    brightnessctl
  ]);
}
# users of dms's brightness plugin need: i2c access and dducutil, brightnessctl in PATH
