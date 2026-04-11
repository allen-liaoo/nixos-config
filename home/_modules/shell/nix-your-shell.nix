{
  lib,
  config,
  pkgs,
  ...
}:

{
  programs.fish.interactiveShellInit = lib.mkIf config.programs.fish.enable ''
    ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source
  '';
}
