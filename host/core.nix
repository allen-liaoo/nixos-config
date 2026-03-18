{ pkgs, aln, ... }:
{
  imports = [
    ./_modules/nixos.nix
    ./_modules/shell.nix
    ./_modules/sops.nix
    ./_modules/sshd.nix
  ];
}
