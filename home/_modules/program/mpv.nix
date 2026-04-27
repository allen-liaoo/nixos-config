{
  pkgs,
  ...
}:
  
{
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      autosub
      mpris
    ];
  };

  # TODO: Wait for Tampermonkey support: https://github.com/Tampermonkey/tampermonkey/issues/2002#issuecomment-2000358691
  # home.packages = [
  #   pkgs.mpv-handler
  # ];
  # TODO: add mime types
}
