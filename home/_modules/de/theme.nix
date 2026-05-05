{
  pkgs,
  lib,
  aln,
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
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    # cursorTheme is set by pointerCursor module
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";  
  };
}
