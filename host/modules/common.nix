{ pkgs, customLib, ... }:
{
  imports = [
    ./nixos.nix
    ./shell.nix
    ./sshd.nix
  ];
}
