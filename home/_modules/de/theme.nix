{
  pkgs,
  alnLib,
  ...
}:

{
  home.pointerCursor = {
    name = "Vimix-cursors";
    package = pkgs.vimix-cursors;
    size = 14;
    x11.enable = true;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    # theme is managed by dms
    # cursorTheme is set by pointerCursor module
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  # user profile picture (used by DMS and detected by accounts service if enabled on system)
  home.file.".face".source = alnLib.relToRoot "assets/me.jpeg";
}
