{
  pkgs,
  lib,
  ...
}:

let
  trashScript = pkgs.writeShellApplication {
    name = "auto-trash";
    runtimeInputs = with pkgs; [ gtrash ];
    text = ''
      gtrash prune --day 14 -f
      gtrash metafix
    '';
  };
in
{
  systemd.user.timers."auto-trash" = {
    Timer = {
      OnCalendar = "daily";
      Persistent = true; # trigger if missed last time
    };
    Install.WantedBy = [ "timers.target" ];
  };
  
  systemd.user.services."auto-trash" = {
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe trashScript;
    };
  };

  # trash dir
  systemd.user.tmpfiles.rules = [
    "L %h/Trash - - - - %h/.local/share/Trash/files"
  ];
}
