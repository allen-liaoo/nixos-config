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

  aln.niri.configFile."mpv" = {
    enable = true;
    content = ''
      window-rule {
        match app-id=r#"mpv"#
        open-fullscreen true
      }
    '';
  };

  # TODO: Wait for Tampermonkey support: https://github.com/Tampermonkey/tampermonkey/issues/2002#issuecomment-2000358691
  # home.packages = [
  #   pkgs.mpv-handler
  # ];
  # TODO: add mime types
}
