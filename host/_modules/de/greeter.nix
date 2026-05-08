{
  inputs,
  pkgs,
  alnLib,
  ...
}:

{
  imports = [
    inputs.dms.nixosModules.greeter
  ];

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";
    configFiles = [
      "/var/cache/dms-greeter/settings.json"
      "/var/cache/dms-greeter/session.json"
    ];
    logs = {
      save = true;
      path = "/tmp/dms-greeter.log";
    };
  };

  # symlink dms-greeter config files
  systemd.tmpfiles.rules =
    let
      settingsJson = pkgs.writeText "settings.json" (
        builtins.toJSON {
          #currentThemeName = "blue";
        }
      );
      sessionJson = pkgs.writeText "session.json" (
        builtins.toJSON {
          wallpaperPath = alnLib.relToRoot "assets/wallpaper/roadtrip.jpg";
          wallpaperFillMode = "PreserveAspectCrop";
        }
      );
    in
    [
      "d /var/cache/dms-greeter 0755 root root -"
      "C+ /var/cache/dms-greeter/settings.json - - - - ${settingsJson}"
      "C+ /var/cache/dms-greeter/session.json - - - - ${sessionJson}"
    ];
}
