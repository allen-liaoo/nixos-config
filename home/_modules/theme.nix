{
  pkgs,
  lib,
  aln,
  ...
}:

lib.optionalAttrs aln.ctx.host.is.gui {
  # cursor
  home.pointerCursor = {
    name = "Vimix-cursors";
    package = pkgs.vimix-cursors;
    size = 14;
    x11.enable = true;
    gtk.enable = true;
  };

  # icon
  gtk = {
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };
}
