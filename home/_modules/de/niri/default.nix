{ lib, pkgs, config, aln, ... }:

{
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./config.kdl);
  xdg.configFile."niri/binds.kdl".source = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./binds.kdl);
}
# wrap in nixGL to fix OpenGL under nix in non-Nixos systems
// (lib.optionalAttrs aln.ctx.host.is.generic-linux { # no need to install on nixos (we do so system wide)
  home.packages = [ (config.lib.nixGL.wrap pkgs.niri) ];
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
