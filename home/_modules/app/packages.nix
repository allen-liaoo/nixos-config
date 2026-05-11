{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwarden-desktop
    loupe # image viewer
    nautilus # file browser
    signal-desktop
    spotify
    zotero
  ];
}
