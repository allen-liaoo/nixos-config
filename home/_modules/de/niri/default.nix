{
  lib,
  pkgs,
  config,
  alnLib,
  ctx,
  ...
}:

let
  symlinkTo =
    f: f |> alnLib.outOfStoreRelToRoot config.home.homeDirectory |> config.lib.file.mkOutOfStoreSymlink;
  configFileModule = (
    { config, name, ... }:
    {
      options = {
        enable = lib.mkEnableOption name;
        content = lib.mkOption {
          type = lib.types.separatedString "\n";
        };
        fileDeriv = lib.mkOption {
          type = lib.types.package;
          readOnly = true;
          default = pkgs.writeText "${name}.kdl" config.content;
        };
      };
    }
  );
in
{
  options = {
    aln.niri = {
      config = lib.mkOption {
        type = lib.types.separatedString "\n";
      };
      configFile = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule configFileModule);
        default = { };
        description = "attrset of config files to be included in niri configs";
      };
    };
  };

  config = lib.mkMerge [
    {
      xdg.configFile."niri/config.kdl".text = ''
        include "${symlinkTo ./general.kdl}"
        include "${symlinkTo ./binds.kdl}"

        ${config.aln.niri.config}

        ${
          config.aln.niri.configFile
          |> builtins.attrValues
          |> builtins.filter (c: c.enable)
          |> lib.map (c: ''
            include "${c.fileDeriv}"
          '')
          |> lib.concatStrings
        }
      '';

      home.packages = [ pkgs.xwayland-satellite ];
    }
    # wrap in nixGL to fix OpenGL under nix in non-Nixos systems
    (lib.optionalAttrs ctx.host.is.generic-linux {
      # no need to install on nixos (we do so system wide)
      home.packages = [ (config.lib.nixGL.wrap pkgs.niri) ];
    })
  ];
}

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
