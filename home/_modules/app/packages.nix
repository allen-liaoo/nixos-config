{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwarden-desktop
    loupe # image viewer
    nautilus # file browser
    prismlauncher # TODO: has module in unstable
    signal-desktop
    zotero
  ];
}
