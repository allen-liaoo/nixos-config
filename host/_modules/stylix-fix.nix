{
  # Stylix needs dconf enabled for some reason
  # https://github.com/nix-community/stylix/issues/139
  programs.dconf.enable = true;
}
