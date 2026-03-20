{ config, pkgs, lib, aln, ... }:

{
  imports = aln.lib.listDirFiles ./. ++ [
    ../core.nix
    ../_modules/sops_nix_config_deploy.nix
  ];
}
