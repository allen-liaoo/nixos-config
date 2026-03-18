{ pkgs, aln, ... }:
{
  imports = [
    ./core.nix
    ./_modules/font.nix
  ];
}
