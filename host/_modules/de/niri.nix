{ lib, inputs, pkgs, aln, ... }:

{
  programs.niri.enable = true;
  hardware.graphics.enable = true;

  systemd.tmpfiles.rules = let 
    dmsDir = "/dms-greeter/";
    settingsJson = pkgs.writeText "settings.json" (builtins.toJSON {
      currentThemeName = "blue";
    });
    sessionJson = pkgs.writeText "session.json" (builtins.toJSON {
      wallpaperPath = aln.lib.relToRoot "assets/wallpaper/wallpaper-night.jpg";
      wallpaperFillMode = "PreserveAspectCrop";
    });
  in [
    "d /var/cache/dms-greeter 0755 root root -"
    "L+ /var/cache/dms-greeter/settings.json - - - - ${settingsJson}"
    "L+ /var/cache/dms-greeter/session.json - - - - ${sessionJson}"
  ];

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";  # Or "hyprland" or "sway"
    package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
    logs = {
      save = true;
      path = "/tmp/dms-greeter.log";
    };
  };

  # tui greeter
  #environment.systemPackages = with pkgs; [ tuigreet ];
  #services.greetd = {
    #enable = true;
    #settings.default_session = {
      #command = "tuigreet --theme border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red --asterisks --asterisks-char * --time --remember --cmd niri";
      #user = "pig";
    #};
  #};
}
