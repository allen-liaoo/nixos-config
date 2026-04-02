{ lib, pkgs, config, aln, ... }:

{
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./config.kdl);
}
// (let 
  niri-wrapped = config.lib.nixGL.wrap pkgs.niri; # wrap in nixGL to fix OpenGL under nix in non-Nixos systems
in lib.optionalAttrs aln.ctx.host.is.generic-linux { # no need to install on nixos (we do so system wide)
  home.packages = [ niri-wrapped ];
})

# NOTE: Assuming user does not have sudo priviledges,
# to get niri to start, log in via TTY and run niri-session
# This will start a "niri" as a systemd service in the TTY
# If user does have sudo priviledges, place below in /usr/share/wayland-session/niri.desktop (at least for GDM) then select Niri when login
/*
[Desktop Entry]
Name=Niri
Comment=A scrollable-tiling Wayland compositor
Exec=niri-session
Type=Application
DesktopNames=niri
*/
