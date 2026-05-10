{
  lib, 
  ctx,
  ...
}:

let
  # cant simply check config.groups.input because hardware.uinput references it (infinite rec)
  enable = ctx.host.users |> map (u: u.groups) |> lib.flatten |> builtins.elem "input";
in
{
  hardware.uinput.enable = enable; 
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", TAG+="uaccess", MODE:="0660", OPTIONS+="static_node=uinput"
  '';
}
# users of xremap need to be in group uinput
